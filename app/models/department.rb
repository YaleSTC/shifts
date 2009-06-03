class Department < ActiveRecord::Base
  has_many :loc_groups
  belongs_to :permission
  before_validation_on_create :create_user_admin_permission
  before_validation_on_update :update_user_admin_permission
  validates_uniqueness_of :name
  validates_uniqueness_of :permission_id

  has_and_belongs_to_many :users
  has_many :roles

  private
  def create_user_admin_permission
    self.create_permission(:name => name + " user admin")
  end

  # in case department name is changed, should update accordingly
  def update_user_admin_permission
    self.permission.update_attribute(:name, name + " user admin")
  end

end

