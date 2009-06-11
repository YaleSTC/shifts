class Category < ActiveRecord::Base
  belongs_to :department
  has_many :payform_items

  validates_presence_of :department

end

