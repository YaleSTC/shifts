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

  delegate :department, :to => :payform
  delegate :user, :to => :payform  
  
  validates_presence_of :date, :category_id, :payform_id
  validates_numericality_of :hours, :greater_than => 0
  validates_presence_of :reason, :on => :update
  validate :length_of_description
  validate_on_update :length_of_reason

  named_scope :active, :conditions => {:active =>  true}
  named_scope :in_category, lambda { |category| { :conditions => {:category_id => category.id}}}
  
  def add_errors(e)
    e = e.to_s.gsub("Validation failed: ", "")
    e.split(", ").each do |error| 
      errors.add_to_base(error)
    end
  end
  
  protected

  def length_of_description
    min = self.department.department_config.description_min.to_i 
    errors.add(:description, "must be at least #{min} characters long.") if self.description.length < min
  end   
  
  def length_of_reason
    min = self.department.department_config.reason_min.to_i
    errors.add(:reason, "must be at least #{min} characters long.") if self.reason.length < min
  end   

  def validate
    errors.add(:date, "cannot be in the future") if date > Date.today
  end

end

