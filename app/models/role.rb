class Role < ActiveRecord::Base
  has_and_belongs_to_many :departments
  has_and_belongs_to_many :permissions
  has_and_belongs_to_many :users
  validates_presence_of :name
  validate :must_belong_to_department

  # FIXME: only role of user admin permission can belong to more than one department. should user_admin role and loc_group roles be separated?
  def must_belong_to_department
    errors.add("Role must belong to a department.", "") if self.departments.empty?
  end
  
  def must_have_unique_name_in_dept
    errors.add("Role must have a unique name within department.", "") if find(:first, :conditions => {:name => self.name, :department => self.department})
  end
end