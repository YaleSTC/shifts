class Payform < ActiveRecord::Base

  has_many :payform_items
  belongs_to :department
  belongs_to :user
  belongs_to :approved_by, :class_name => "User", :foreign_key => "approved_by_id"

  def status
    if printed
      "printed"
    elsif approved
      "approved"
    elsif submitted
      "submitted"
    else
      "unsubmitted"
    end
  end

  #CUSTOM URL -- STILL REQUIRES ID AT FRONT, BUT LOOKS FRIENDLIER
  def to_param
    "#{id}-#{date}"
  end

  def self.build(dept, usr, given_date)
    period_date = Payform.default_period_date(given_date, dept)
    Payform.find(:first, :conditions => {:user_id => usr.id, :department_id => dept.id, :date => period_date}) ||
    Payform.create(:user_id => usr.id, :department_id => dept.id, :date => period_date)
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

