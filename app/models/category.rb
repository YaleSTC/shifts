class Category < ActiveRecord::Base
  belongs_to :department
  has_many :payform_items

end

