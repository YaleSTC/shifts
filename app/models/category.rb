class Category < ActiveRecord::Base
  belongs_to :department
  has_many :payform_items

  validates_presence_of :name, :department_id
  
  named_scope :active,   lambda { |dept_id| { :conditions => ['department_id = ? and active = ?',  dept_id, 1]}}
  named_scope :disabled, lambda { |dept_id| { :conditions => ['department_id = ? and active = ?', dept_id, 0]}}    
  
  
  protected
  
  def validate
    for category in department.categories
        errors.add(:category, "name already taken") if name == category.name and id != category.id
    end
  end

end

