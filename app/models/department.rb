class Department < ActiveRecord::Base
  has_many :loc_groups, :dependent => :destroy
  belongs_to :admin_permission, :class_name => "Permission", :dependent => :destroy
  has_many :departments_users, :dependent => :destroy
  has_many :users, :through => :departments_users
  has_many :locations, :through => :loc_groups
  has_many :data_types, :dependent => :destroy
  has_many :data_objects, :through => :data_types
  belongs_to :admin_permission,
              :class_name => "Permission",
              :foreign_key => "permission_id",
              :dependent => :destroy
  has_many :payforms
  has_many :payform_sets
  has_many :categories

  has_many :user_source_links, :as => :user_source
  has_many :location_source_links, :as => :location_source

  before_validation_on_create :create_permissions
# this next validation doesn't work -cmk
  before_validation_on_update :update_permissions
  validates_uniqueness_of :name
  validates_uniqueness_of :admin_permission_id

  has_and_belongs_to_many :users
  has_and_belongs_to_many :roles

  private
  def create_permissions
    self.create_admin_permission(:name => name + " dept admin")
  end

  # in case department name is changed, should update permissions accordingly
  def update_permissions
    self.admin_permission.update_attribute(:name, name + " dept admin")
  end

end
