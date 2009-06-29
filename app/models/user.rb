require 'net/ldap'
class User < ActiveRecord::Base
  has_and_belongs_to_many :roles
  has_one :user_config
  has_many :departments_users
  has_many :departments, :through => :departments_users
  has_many :payforms
  has_many :shifts
  has_many :notices, :as => :author
  has_many :notices, :as => :remover
  has_many :user_source_links, :as => :user_source

  validates_presence_of :first_name
  validates_presence_of :last_name
  validates_presence_of :login
  validates_uniqueness_of :login
  validate :departments_not_empty
  
  after_create :create_user_config
  before_destroy :destroy_user_config

  # memoize allows more powerful caching of instance variable in methods
  # memoize line must be added after the method definitions (see below)
  extend ActiveSupport::Memoizable

  def self.import_from_ldap(login, department, should_save = false)
    # Setup our LDAP connection
    ldap = Net::LDAP.new( :host => "directory.yale.edu", :port => 389 )
    begin
      # We filter results based on login
      filter = Net::LDAP::Filter.eq("uid", login)
      new_user = User.new(:login => login)
      ldap.open do |ldap|
        # Search, limiting results to yale domain and people
        ldap.search(:base => "ou=People,o=yale.edu", :filter => filter, :return_result => false ) do |entry|
          # Make sure only 1 record is found
          Rails.logger.info(entry)
          raise "LDAP: more than one result is found" if entry['givenname'].size > 1

          new_user.first_name = entry['givenname'].first
          new_user.last_name  = entry['sn'].first
          new_user.email = entry['mail'].first

        end
        #add the user to the currently selected department
        new_user.departments << department
      end
      new_user.save if should_save
    rescue Exception => e
      new_user.errors.add_to_base "Error: #{e.message}" # Will trigger an error, LDAP is probably down
    end
    new_user
  end

  def self.mass_add(logins, department)
    failed = []

    logins.split(/\W+/).map do |n|
      if user = self.find_by_login(n)
        user.departments << department
      else
        user = import_from_ldap(n, department, true)
      end
      failed << "From login #{user.login}: #{user.errors.full_messages.to_sentence} (LDAP import may have failed)" if user.new_record?
    end

    failed
  end

  def self.search(search_string)
    self.all.each do |u|
      if u.name == search_string || u.proper_name == search_string || u.awesome_name == search_string || u.login == search_string
        @found_user =  u
      end
    end
    @found_user
  end

  def permission_list
    roles.collect { |r| r.permissions }.flatten
  end

  def current_shift
    self.shifts.select{|shift| shift.signed_in? and !shift.submitted?}[0]
  end

  # check if a user can see locations and shifts under this loc group
  def can_view?(loc_group)
    self.is_superuser? || permission_list.include?(loc_group.view_permission) && self.is_active?(loc_group.department)
  end

  # check if a user can sign up for a shift in this loc group
  def can_signup?(loc_group)
    self.is_superuser? || permission_list.include?(loc_group.signup_permission) && self.is_active?(loc_group.department)
  end

#   check for loc group admin, who can add locations and shifts under it
#   DEPRECATED IN FAVOR OF EXTENDING is_admin_of? -Ben
#  def can_admin?(loc_group)
#    self.is_superuser? || (permission_list.include?(loc_group.admin_permission) || self.is_superuser?) && self.is_active?(loc_group.department)
#  end

  # check for admin permission given a dept, location group, or location
  def is_admin_of?(thing)
    self.is_superuser? || (permission_list.include?(thing.admin_permission) && self.is_active?(thing))
  end

  # see list of superusers defined in config/initializers/superuser_list.rb
  def is_superuser?
    SUPERUSER_LIST.include?(self.login)
  end

  # check to make sure the user is "active" in the given dept
  def is_active?(dept)
    self.departments_users[0].active
  end

  # Given a department, check to see if the user can admin any loc groups in it
  def is_loc_group_admin?(dept)
    dept.loc_groups.any?{|lg| self.is_admin_of?(lg)}
  end

  # Given a department, return any location groups within that department that the user can admin
  def loc_groups_to_admin(dept)
    return dept.loc_groups if self.is_admin_of?(dept)
    dept.loc_groups.delete_if{|lg| !self.is_admin_of?(lg)}
  end

  def name
    [((nick_name.nil? or nick_name.length == 0) ? first_name : nick_name), last_name].join(" ")
  end

  def proper_name
    [first_name, last_name].join(" ")
  end

  def awesome_name
    [nick_name ? [first_name, "\"#{nick_name}\"", last_name] : self.name].join(" ")
  end

  #This method is needed to make polymorphic associations work
  def users
    [self]
  end

  def available_sub_requests
    SubRequest.all.select{|sr| sr.substitutes.include?(self)}
  end

  def notices
    Notice.active.select{|n| n.viewers.include?(self)}
  end

  memoize :name, :permission_list, :is_superuser?


  private

  def departments_not_empty
    errors.add("User must have at least one department.", "") if departments.empty?
  end
  
  def create_user_config
    UserConfig.new({:user_id => self.id}).save
  end
  
  def destroy_user_config
    self.user_config.destroy
  end
    
end
