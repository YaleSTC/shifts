class PayformItemSet < ActiveRecord::Base

  has_many :payform_items
  belongs_to :category
  delegate :department, :to => :category
  belongs_to :approved_by, :class_name => "User", :foreign_key => "approved_by_id"
  validates_presence_of :description, :hours, :date, :category_id
  
end

