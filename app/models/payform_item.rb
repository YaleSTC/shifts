class PayformItem < ActiveRecord::Base

  belongs_to :payform
  belongs_to :category
  belongs_to :payform_item
  belongs_to :user

end

