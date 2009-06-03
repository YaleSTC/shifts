class Department < ActiveRecord::Base
  has_many :loc_groups
  belongs_to :permission, :dependent => :destroy
  belongs_to :deactivated_permission,
              :class_name => "Permission",
              :foreign_key => "deactive_perm_id",
              :dependent => :destroy
   has_and_belongs_to_many :users

  before_validation_on_create :create_permissions
  before_validation_on_update :update_permissions
  validates_uniqueness_of :name
  validates_uniqueness_of :permission_id

  has_and_belongs_to_many :users
  has_many :roles

  private
  def create_permissions
    self.create_permission(:name => name + " user admin")
    self.create_deactivated_permission(:name => "Deactivated in " + name)
  end

  # in case department name is changed, should update permissions accordingly
  def update_permissions
    self.permission.update_attribute(:name, name + " user admin")
    self.deactivated_permission.update_attribute(:name,"Deactivated in " + name)
  end

end

