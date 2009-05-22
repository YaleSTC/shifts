class Department < ActiveRecord::Base
  has_many :loc_groups
  belongs_to :permission
  before_validation_on_create :create_permission
  before_validation_on_update :update_permission
  validates_uniqueness_of :name
  validates_presence_of :permission_id

  has_and_belongs_to_many :users
  private
  def create_permission
    self.permission = Permission.create(:name => name + " user admin")
  end

  # in case department name is changed, should update accordingly
  def update_permission
    self.permission.update_attribute(:name, name + " user admin")
  end
end

