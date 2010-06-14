require 'net/ldap'
class User < ActiveRecord::Base
  acts_as_csv_importable :normal, [:login, :first_name, :nick_name, :last_name, :email, :employee_id, :role]
  acts_as_csv_exportable :normal, [:login, :first_name, :nick_name, :last_name, :email, :employee_id, :role]
  acts_as_authentic do |options|
    options.maintain_sessions false
  end
  
  has_and_belongs_to_many :roles
  has_many :departments_users
  has_many :departments, :through => :departments_users
  has_many :payforms
  has_many :payform_items, :through => :payforms
  has_many :permissions, :through => :roles
  has_many :shifts
  has_many :notices, :as => :author
  has_many :notices, :as => :remover
  has_one  :punch_clock
  has_many :sub_requests

# New user configs are created by a user observer, after create
  has_one :user_config, :dependent => :destroy
  has_one :user_profile, :dependent => :destroy

  attr_protected :superusercreate_
  named_scope :superusers, :conditions => { :superuser => true }, :order => :last_name
  delegate :default_department, :to => 'user_config'

  validates_presence_of :first_name
  validates_presence_of :last_name
  validates_presence_of :login
  validates_presence_of :auth_type
  validates_uniqueness_of :login
  validate :departments_not_empty

  extend ActiveSupport::Memoizable

  def role=(name)
    self.roles << Role.find_by_name(name) if name && Role.find_by_name(name)
  end

  def role
    self.roles.first.name if self.roles.first
  end

  def set_random_password(size=20)
    chars = (('a'..'z').to_a + ('0'..'9').to_a)
    self.password=self.password_confirmation=(1..size).collect{|a| chars[rand(chars.size)] }.join
  end

  def self.search_ldap(first_name, last_name, email, limit)
    appconfig = AppConfig.first
    first_name+='*'
    last_name+='*'
    email+='*'
    # Set up our LDAP connection
    begin
      ldap = Net::LDAP.new( :host => appconfig.ldap_host_address, :port => appconfig.ldap_port )
      filter = Net::LDAP::Filter.eq(appconfig.ldap_first_name, first_name) & Net::LDAP::Filter.eq(appconfig.ldap_last_name, last_name) & Net::LDAP::Filter.eq(appconfig.ldap_email, email)
      out=[]
      ldap.open do |ldap|
        ldap.search(:base => appconfig.ldap_base, :filter => filter, :return_result => false) do |entry|
          out << {:login => entry[appconfig.ldap_login][0], :email => entry[appconfig.ldap_email][0], :first_name => entry[appconfig.ldap_first_name][0], :last_name => entry[appconfig.ldap_last_name][0]}
         break if out.length>=limit
        end
      end
      out
    rescue Exception => e
      false
    end
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

  def current_shift
    Shift.find(:first, :conditions=>{:user_id => self.id, :signed_in => true})
  end

# Returns all the loc groups a user can view within a given department
  def loc_groups(dept)
    dept.loc_groups.delete_if{|lg| !self.can_view?(lg)}
  end

  # check if a user can see locations and shifts under this loc group
  def can_view?(loc_group)
    return false unless loc_group
    (permission_list.include?(loc_group.view_permission) || permission_list.include?(loc_group.department.admin_permission)) && self.is_active?(loc_group.department)
  end

  # check if a user can sign up for a shift in this loc group
  def can_signup?(loc_group)
    return false unless loc_group
    permission_list.include?(loc_group.signup_permission) && self.is_active?(loc_group.department)
  end
  
  # check if a user has permission to take a sub
  def can_take_sub?(sub_request)
    return false unless sub_request
    can_signup?(sub_request.loc_group)  && (sub_request.user != self) && (sub_request.users_with_permission.include?(self) || sub_request.users_with_permission.blank?)
  end

  # check for admin permission given a dept, location group, or location
  def is_admin_of?(thing)
    return false unless thing 
    ((permission_list.include?(thing.department.admin_permission) || permission_list.include?(thing.admin_permission)) || self.is_superuser?) && self.is_active?(thing.department)
  end

  # Can only be called on objects which have a user method
  def is_owner_of?(thing)
    return false unless thing.user == self
    true
  end

  # now superuser is an attribute of User model, we use this instead
  # supermode lets an user turn on or off his superuser privilege
  # user .superuser? is you wanna test superuser no matter if  supermode is on or not
  def is_superuser?
    superuser? && supermode?
  end

  # check to make sure the user is "active" in the given dept
  def is_active?(dept)
    if DepartmentsUser.find(:first, :conditions => { :user_id => self, :department_id => dept, :active => true})
      true
    else
      false
    end
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

  def full_name_with_nick
    if nick_name && !nick_name.blank?
      [first_name, "'#{nick_name}'" , last_name].join(" ")
    else
      name
    end
  end

  def self.search(search_string)
    User.all.each do |u|
      return u if u.name == search_string || u.proper_name == search_string || u.awesome_name == search_string || u.login == search_string
    end
    nil
  end

  #We do still need this for polymorphism. I want to be able to call @user.users.
  def users
    [self]
  end

  #returns  upcoming sub_requests user has permission to take.  Default is for all departments
  def available_sub_requests(departments)
   @all_subs = SubRequest.find(:all, :conditions => ["end >= ?", Time.now]).select { |sub| self.can_take_sub?(sub) }
   if !departments.blank?
     @all_subs.select {|sub| departments.include?(sub.shift.department) }
   end
  end
  
  def restrictions #TODO: this could probably be optimized
    Restriction.current.select{|r| r.users.include?(self)}
  end

  def toggle_active(department) #TODO why don't we just update the attribues on the current entry and save it?
    new_entry = DepartmentsUser.new();
    old_entry = DepartmentsUser.find(:first, :conditions => { :user_id => self, :department_id => department})
    new_entry.attributes = old_entry.attributes
    new_entry.active = !old_entry.active
    DepartmentsUser.delete_all( :user_id => self, :department_id => department)
    new_entry.save
  end

  def deliver_password_reset_instructions!(mailer)
    self.reset_perishable_token!
    mailer.call(self)
  end

  memoize :name, :permission_list

  def accessible_departments
    (superuser? && supermode?) ? Department.all : departments
  end

  def current_notices
    Notice.active.select {|n| n.users.include?(self)}
  end

  def other_notices
    Notice.active.select {|n| !n.users.include?(self) && n.locations.empty?}
  end


  def payrate(department)
    DepartmentsUser.find(:first, :conditions => { :user_id => self, :department_id => department }).payrate
  end
  
  def set_payrate(value, department)
    new_entry = DepartmentsUser.new();
    old_entry = DepartmentsUser.find(:first, :conditions => { :user_id => self, :department_id => department})
    new_entry.attributes = old_entry.attributes
    new_entry.payrate = value
    DepartmentsUser.delete_all(:user_id => self, :department_id => department)
    new_entry.save
  end

  private

  def departments_not_empty
    errors.add("User must have at least one department.", "") if departments.empty?
  end

end
