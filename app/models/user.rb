require 'net/ldap'
class User < ActiveRecord::Base
  has_and_belongs_to_many :roles
  has_many :departments_users
  has_many :departments, :through => :departments_users
  has_many :shifts

  validates_presence_of :name
  validates_presence_of :login
  validates_uniqueness_of :login
  validate :departments_not_empty

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

          # create name as full name is this user doesn't have a nickname or different name assigned
          new_user.name = new_user.full_name if new_user.name.blank?
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

  def permission_list
    roles.collect { |r| r.permissions }.flatten
  end

  # check if a user can see locations and shifts under this loc group
  def can_view?(loc_group)
    self.is_superuser? || permission_list.include?(loc_group.view_permission) && self.is_active?(loc_group.department)
  end

  # check if a user can sign up for a shift in this loc group
  def can_signup?(loc_group)
    self.is_superuser? || permission_list.include?(loc_group.signup_permission) && self.is_active?(loc_group.department)
  end

  # check for loc group admin, who can add locations and shifts under it
  def can_admin?(loc_group)
    self.is_superuser? || (permission_list.include?(loc_group.admin_permission) || self.is_superuser?) && self.is_active?(loc_group.department)
  end

  # check for department admin, who can create new loc group, new role, and new user in department
  def is_admin_of?(dept)
    self.is_superuser? || permission_list.include?(dept.permission) && self.is_active?(dept)
  end

  # see list of superusers defined in config/initializers/superuser_list.rb
  def is_superuser?
    SUPERUSER_LIST.include?(self.login)
  end

  # check to make sure the user is "active" in the given dept
  def is_active?(dept)
    self.departments_users[0].active
  end

  def full_name
    [first_name, last_name].join(" ")
  end

  memoize :full_name, :permission_list, :is_superuser?

  private

  def departments_not_empty
    errors.add("User must have at least one department.", "") if departments.empty?
  end
end
