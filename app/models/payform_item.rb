class PayformItem < ActiveRecord::Base
  acts_as_tree

  belongs_to :payform
  belongs_to :payform_item_set
	belongs_to :category

  delegate :department, :to => :category
  delegate :user, :to => :payform  # deleted payform items don't have payforms
                                   # and hence no users? This could lead to problems

  # commented out :category_id since it is not fully functional
  # and yet it tries to prevent the creation of new payform_items
  validates_presence_of :description, :date #:category_id
  #validates_presence_of :reason, :unless => :active
  validates_numericality_of :hours

  named_scope :active, lambda { |*args| { :conditions => ['active = ?',  true] } }
  
  protected
  
  def validate
    errors.add(:description, "seems too short") if description.length < 10 and description.length > 0
    #errors.add(:reason, "seems too short") if !active and reason and reason.length < 10 and reason.length > 0
    errors.add(:date, "is invalid") if !Date.valid_civil?(date.year, date.month, date.day)
    errors.add(:date, "cannot be in the future") if date > Time.now.to_date
    #TODO: If it's active, it must belong to a payform. If not, it's an edit.
  end

end
