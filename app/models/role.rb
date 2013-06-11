class Role < ActiveRecord::Base
#  has_and_belongs_to_many :departments
  belongs_to :department
  has_many :restrictions, :as => :restrictable
  has_many :notices, :as => :noticeable
  has_and_belongs_to_many :template
  has_and_belongs_to_many :permissions
  has_and_belongs_to_many :users

  validates_presence_of :name
  validates_presence_of :department_id
  validate :must_have_unique_name_in_dept #can't use scope because of habtm relationship :(

# should be entirely unnecessary now -ben
#  # FIXME: only role of user admin permission can belong to more than one department.
#  # should user_admin role and loc_group roles be separated?
#  def must_belong_to_department
#    errors.add("Role must belong to a department.", "") if self.departments.empty?
#  end

  def must_have_unique_name_in_dept
    #get a list of roles in the same department as this role, excluding this role
#    associated_roles = self.departments.collect{|dept| dept.roles}.flatten - [self]
    associated_roles = self.department.roles - [self]
    errors.add("Name must be unique in a department.", "") unless associated_roles.select{ |role| role.name == self.name }.empty?
  end

	#returns an array of locations that the role can signup at
	def signup_locations
		locations = []
		self.department.loc_groups.each do |loc_group|
			locations << loc_group.locations if self.permissions.include?(loc_group.signup_permission)
		end
		return locations.flatten
	end

end

