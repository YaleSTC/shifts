class Payform < ActiveRecord::Base

  has_many :payform_items
  belongs_to :department
  belongs_to :user

  def to_param
    "#{id}-#{date}"
  end


  def self.current(dept, user)
    period_date = Payform.default_period_date(Date.today, dept)
    payform = Payform.find(:first, :conditions => {:user_id => user,
                                           :department_id => dept,
                                           :date => period_date}) ||
               Payform.create(:user_id => user, :department_id => dept, :date => period_date)
  end

  def self.default_period_date(given_date, dept)
    day = dept.day
    date_day = (dept.monthly ? given_date.mday : given_date.wday)
    subtract = (dept.monthly ? 1.month : 1.week)
    if day > date_day
      given_date = given_date - subtract
    end
    given_date - date_day.days + day.days
  end

end

