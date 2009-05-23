class Role < ActiveRecord::Base
  has_and_belongs_to_many :departments
  has_and_belongs_to_many :permissions
  validates_uniqueness_of :name
end

