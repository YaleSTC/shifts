class Permission < ActiveRecord::Base
  validates_uniqueness_of :name
  has_one :department, :dependent => :destroy
  has_one :department, :foreign_key => 'deactive_perm_id', :dependent => :destroy
  #TODO: add associations with loc group here
end

