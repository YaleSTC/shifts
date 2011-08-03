class Category < ActiveRecord::Base
  belongs_to :department
  has_many :payform_items

  validates_presence_of :name, :department_id
  validates_uniqueness_of :name, :scope => :department_id
  
  scope :disabled, :conditions => { :active   => false }
  scope :active,   :conditions => { :active   => true  }
  scope :built_in, :conditions => { :built_in => true  }
  scope :usable,   :conditions => { :active   => true, :built_in => false }
  
  def self.enabled
    Category.find(:all, :conditions => ["#{:active.to_sql_column} = #{true.to_sql}"])
  end
  
  protected
  
  
end

