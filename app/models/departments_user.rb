class DepartmentsUser < ActiveRecord::Base

  belongs_to :department
  belongs_to :user

  #this model exists so that the join table can have the bool "active"
  #thus, a user can be deactivated in any given department without affecting the others.

end

