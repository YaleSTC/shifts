class LocGroup < ActiveRecord::Base
  belongs_to :department

  belongs_to :view_permission,
              :class_name => "Permission",
              :foreign_key => "view_perm_id"
  belongs_to :signup_permission,
              :class_name => "Permission",
              :foreign_key => "signup_perm_id"
  belongs_to :admin_permission,
              :class_name => "Permission",
              :foreign_key => "admin_perm_id"
  before_validation_on_create :create_permissions
  before_validation_on_update :update_permissions

  validates_presence_of :department

  private

  def create_permissions
    self.create_view_permission(:name => name + " view")
    self.create_signup_permission(:name => name + " signup")
    self.create_admin_permission(:name => name + " admin")
  end

  # in case loc group name is changed, update permission names accordingly
  # note update_attribute does the saving as well
  def update_permissions
    self.view_permission.update_attribute(:name, name + "view")
    self.signup_permission.update_attribute(:name, name + "signup")
    self.admin_permission.update_attribute(:name, name + "admin")
  end
end

