require 'net/ldap'
class User < ActiveRecord::Base
  has_and_belongs_to_many :roles
  has_and_belongs_to_many :departments

  validates_presence_of :name
  validates_presence_of :netid
  validates_uniqueness_of :netid
  validate :departments_not_empty

  def self.import_from_ldap(netid, department, should_save = false)
    # Setup our LDAP connection
    ldap = Net::LDAP.new( :host => "directory.yale.edu", :port => 389 )
    begin
      # We filter results based on netid
      filter = Net::LDAP::Filter.eq("uid", netid)
      new_user = User.new(:netid => netid)
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

  def self.mass_add(netids, department)
    failed = []

    netids.split(/\W+/).map do |n|
      user = import_from_ldap(n, department, true)
      failed << "From netid #{user.netid}: #{user.errors.full_messages.to_sentence}" if user.new_record?
    end

    failed
  end

  def permission_list
    @pl ||= roles.collect { |r| r.permissions }. flatten
  end

  # check if a user can see locations and shifts under this loc group
  def can_view?(loc_group)
    permission_list.include?(loc_group.view_permission) && self.is_active?
  end

  # check if a user can sign up for a shift in this loc group
  def can_signup?(loc_group)
    permission_list.include?(loc_group.signup_permission) && self.is_active?
  end

  # check for loc group admin, who can add locations and shifts under it
  def can_admin?(loc_group)
    permission_list.include?(loc_group.admin_permission) && self.is_active?
  end

  # check for department admin, who can create new loc group, new role, and new user in department
  def is_admin_of?(dept)
    permission_list.include?(dept.permission) && self.is_active?
  end

  # check to make sure the user does not have the "deactivated" role
  def is_active?
    not permission_list.include?(dept.deactivated_permission)
  end

  def full_name
    [first_name, last_name].join(" ")
  end

  private

  def departments_not_empty
    errors.add("User must have at least one department.", "") if departments.empty?
  end
end

