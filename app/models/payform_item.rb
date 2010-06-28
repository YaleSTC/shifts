class PayformItem < ActiveRecord::Base
  versioned
  
  # acts_as_tree - replaced by 'versioned'
  
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
  
  validates_presence_of :date, :category_id, :payform_id
  validate :length_of_description
  validate_on_update :proper_reason
  validates_numericality_of :hours
  validate :hours_greater_than_zero
  
  named_scope :active, :conditions => {:active =>  true}
  
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
    if self.description.length < self.payform.department.department_config.description_min.to_i 
      errors.add_to_base("Description must be at least #{min} characters long.") 
    end
  end   
  
  def proper_reason
    unless self.version == 1 #we haven't done any versioning yet
      min = self.payform.department.department_config.reason_min.to_i
      unless (self.reason.nil?)
        errors.add_to_base("Reason must be at least #{min} characters long.") if self.reason.length < min
      else
        errors.add_to_base("You must include a reason.")
      end
    end
  end   

  def validate
    errors.add(:date, "cannot be in the future") if date > Date.today
  end

end

