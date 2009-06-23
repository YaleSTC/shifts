class Category < ActiveRecord::Base
  belongs_to :department
  has_many :payform_items

  validates_presence_of :name, :department_id
  validates_uniqueness_of :name, :scope => :department_id
  
  named_scope :disabled, :conditions => { :active => false }
  named_scope :active, :conditions => { :active => true }
  
  def self.enabled
    Category.find(:all, :conditions => ['active = ?', true])
  end
  
  protected
  
  
end

