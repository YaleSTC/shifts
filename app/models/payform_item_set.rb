class PayformItemSet < ActiveRecord::Base

  has_many :payform_items
  
  delegate :department, :to => :category
  delegate :user, :to => :payform
  
  validates_presence_of :description, :hours, :date, :category_id
  
end

