class PayformItem < ActiveRecord::Base

  belongs_to :payform
  belongs_to :payform_item
  belongs_to :category

  delegate :department, :to => :category
  delegate :user, :to => :payform

  validates_presence_of :payform_id, :category_id, :description, :date
  validates_numericality_of :hours
  validates_presence_of :reason, :unless => :active?

  named_scope :active, lambda { |*args| { :conditions => ['active = ?',  true] } }
  
  
  
  protected
  
  def validate
    errors.add(:reason, "seems too short") if !active and reason.length < 10 and reason.length > 0
    errors.add(:description, "seems too short") if description.length < 10 and description.length > 0
    errors.add(:date, "is invalid") if !Date.valid_civil?(date.year, date.month, date.day)
    errors.add(:date, "cannot be in the future") if date > Time.now.to_date
  end

end

