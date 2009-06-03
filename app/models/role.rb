class Role < ActiveRecord::Base
  belongs_to :department
  has_and_belongs_to_many :permissions
  has_and_belongs_to_many :users
  validates_presence_of :name
  validates_uniqueness_of :name, :scope => :department_id
  validate :must_belong_to_department

  # FIXME: only role of user admin permission can belong to more than one department. should user_admin role and loc_group roles be separated?
  def must_belong_to_department
    errors.add("Role must belong to a department.", "") if self.department_id.nil?
  end
end

