class Permission < ActiveRecord::Base
  validates_uniqueness_of :name
  has_one :department
  has_one :loc_group,
           foreign_key: 'view_perm_id'
  has_one :loc_group,
           foreign_key: 'signup_perm_id'
  has_one :loc_group,
           foreign_key: 'admin_perm_id'
end

