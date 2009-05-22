class Permission < ActiveRecord::Base
  validates_uniqueness_of :name
  has_one :department
  #TODO: add associations with loc group here
end

