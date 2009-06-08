class Payform < ActiveRecord::Base

  has_many :payform_items
  belongs_to :department
  belongs_to :user

  def self.current(department, user)
    Payform.find(:conditions => {:user_id => user, :department_id => department, :date => Payform.period_date(Date.today, department)}
  end

  def self.period_date(date, department)

  end

end

