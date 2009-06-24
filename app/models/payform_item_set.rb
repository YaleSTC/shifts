class PayformItemSet < ActiveRecord::Base

  has_many :payform_items
  belongs_to :category
  delegate :department, :to => :category
  
  validates_presence_of :description, :hours, :date, :category_id
  
end

