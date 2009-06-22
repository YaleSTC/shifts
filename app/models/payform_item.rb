class PayformItem < ActiveRecord::Base

  belongs_to :payform
  belongs_to :payform_item
  belongs_to :payform_item_set
		belongs_to :category

  delegate :department, :to => :category
  delegate :user, :to => :payform

  validates_presence_of :category_id, :description, :date
  validates_numericality_of :hours
  validates_presence_of :reason, :if => :payform_item_id

  named_scope :active, lambda { |*args| { :conditions => ['active = ?',  true] } }
  
  
  
  protected
  
  def validate
    errors.add(:description, "seems too short") if description.length < 10 and description.length > 0
    errors.add(:date, "is invalid") if !Date.valid_civil?(date.year, date.month, date.day)
    errors.add(:date, "cannot be in the future") if date > Time.now.to_date
    #TODO: If it's active, it must belong to a payform. If not, it's an edit.
  end

end
