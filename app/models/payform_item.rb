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
  validates_length_of :description, :minimum => 10
  validates_length_of :reason, :minimum => 10, :unless => :active
  validates_numericality_of :hours

  named_scope :active, :conditions => {:active =>  true}
  
  protected

  def validate
    errors.add(:date, "cannot be in the future") if date > Date.today
  end

end

