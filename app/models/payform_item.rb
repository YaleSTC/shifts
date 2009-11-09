class PayformItem < ActiveRecord::Base
  acts_as_tree
  
  # acts_as_ascii_tree
  #     /\
  #    / .\
  #   / . .\
  #  /______\
  #    |__|

  belongs_to :payform
  belongs_to :payform_item_set
  belongs_to :category

  delegate :department, :to => :category
  delegate :user, :to => :payform  
  
  validates_presence_of :date, :category_id
  validate :length_of_description
  validate_on_update :length_of_reason
  validates_numericality_of :hours
  validate :hours_greater_than_zero
  
  named_scope :active, :conditions => {:active =>  true}
  
  def user 
    if self.payform != nil
      user = self.payform.user 
    elsif self.parent and self.parent.payform
      user = self.parent.payform.user 
    end
  end
  
  def add_errors(e)
    e = e.to_s.gsub("Validation failed: ", "")
    e.split(", ").each do |error| 
      errors.add_to_base(error)
    end
  end
  
  protected
  
  def hours_greater_than_zero
    unless self.hours.to_f > 0
      errors.add_to_base("Your payform item has no hours.") 
    end
  end

  def length_of_description
    if self.payform_id == nil
      min = PayformItem.find_by_parent_id(self.id).payform.department.department_config.description_min.to_i
    else
      min = self.payform.department.department_config.description_min.to_i
    end
    if self.description.length < min 
      errors.add_to_base("Description must be at least #{min} characters long.") 
    end
  end   
  
  def length_of_reason
    if self.active == false
      min = self.payform.department.department_config.reason_min.to_i
      errors.add_to_base("Reason must be at least #{min} characters long.") if self.reason.length < min
    elsif self.reason != nil
      min = PayformItem.find_by_parent_id(self.id).payform.department.department_config.reason_min.to_i
      errors.add_to_base("Reason must be at least #{min} characters long.") if self.reason.length < min 
    end
  end   

  def validate
    errors.add(:date, "cannot be in the future") if date > Date.today
  end

end

