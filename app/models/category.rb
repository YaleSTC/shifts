class Category < ActiveRecord::Base
  belongs_to :department
  has_many :payform_items

  validates_presence_of :name, :department_id
  validates_uniqueness_of :name, :scope => :department_id
  
  named_scope :disabled, :conditions => { :active => false }
  default_scope :conditions => { :active => true }
  
  protected
  

end

