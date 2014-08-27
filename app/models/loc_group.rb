# == Schema Information
#
# Table name: loc_groups
#
#  id             :integer          not null, primary key
#  name           :string(255)
#  department_id  :integer
#  view_perm_id   :integer
#  signup_perm_id :integer
#  admin_perm_id  :integer
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  public         :boolean          default(TRUE)
#  active         :boolean          default(TRUE)
#

class LocGroup < ActiveRecord::Base
  belongs_to :department
  belongs_to :view_permission,
              class_name: "Permission",
              foreign_key: "view_perm_id",
              dependent: :destroy
  belongs_to :signup_permission,
              class_name: "Permission",
              foreign_key: "signup_perm_id",
              dependent: :destroy
  belongs_to :admin_permission,
              class_name: "Permission",
              foreign_key: "admin_perm_id",
              dependent: :destroy
  has_many :locations, dependent: :destroy

  # These make loc groups connect to the superclass notice, as well as its subclasses
  has_and_belongs_to_many :announcements, join_table: :loc_groups_notices, association_foreign_key: :notice_id
  has_and_belongs_to_many :links,         join_table: :loc_groups_notices, association_foreign_key: :notice_id
  has_and_belongs_to_many :stickies,      join_table: :loc_groups_notices, association_foreign_key: :notice_id
  has_and_belongs_to_many :notices

  scope :active, where(active: true)

  before_validation(on: :create) {:create_permissions}
  before_validation(on: :update) {:update_permissions}

  validates_presence_of :department

  def permissions
    [view_permission, signup_permission, admin_permission]
  end

  # Conventional has_many :through won't work -Ben
  def data_objects
    self.locations.map{|loc| loc.data_objects}.flatten.uniq.compact
  end

  def users
    department.users.select { |u| u.can_signup?(self) }
  end

  def roles
    department.roles.select { |u| u.permissions.include?(signup_permission) }
  end

  def deactivate
    self.active = false
    self.save!
    self.locations.each do |location|
     location.deactivate
    end
  end

  def activate
    self.active = true
    self.save!
    self.locations.each do |location|
      location.activate
    end
  end

  private

  def create_permissions
    self.create_view_permission(name: name + " view")
    self.create_signup_permission(name: name + " signup")
    self.create_admin_permission(name: name + " admin")
  end

  # in case loc group name is changed, update permission names accordingly
  # note update_attribute does the saving as well
  def update_permissions
    self.view_permission.update_attribute(:name, name + " view")
    self.signup_permission.update_attribute(:name, name + " signup")
    self.admin_permission.update_attribute(:name, name + " admin")
  end


end
