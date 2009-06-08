class Payform < ActiveRecord::Base

  has_many :payform_items
  belongs_to :department
  belongs_to :user

  def current(current_department, current_user)
    Payform.find_by_w
  end


end

