class Payform < ActiveRecord::Base

  has_many :payform_items
  belongs_to :department
  belongs_to :user

  #CUSTOM URL -- STILL REQUIRES ID AT FRONT, BUT LOOKS FRIENDLIER
  def to_param
    "#{id}-#{date}"
  end

  def self.build(dept, user, date)
    period_date = Payform.default_period_date(date, dept)
    Payform.find(:first, :conditions => {:user_id => user, :department_id => dept, :date => period_date}) ||
    Payform.create(:user_id => user, :department_id => dept, :date => period_date)
  end

  def self.default_period_date(given_date, dept)
    if dept.monthly
      given_date_day = given_date.mday
      if dept.end_of_month 
        dept.day = given_date.end_of_month
      end
      if dept.day < given_date_day
        given_date = given_date + 1.month
      end
    else
      given_date_day = given_date.wday
      if dept.day < given_date_day
        given_date = given_date + 1.week
      end
    end
    given_date - given_date_day.days + dept.day.days
  end

end

