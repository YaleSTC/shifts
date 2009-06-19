class Category < ActiveRecord::Base
  belongs_to :department
  has_many :payform_items

  validates_presence_of :name, :department_id, :active
  validates_uniqueness_of :name, :scope => :department_id
  
  named_scope :active,   { :conditions => ['active = ?', true]}
  named_scope :disabled, { :conditions => ['active = ?', false]}
  
  
  protected
  

end

