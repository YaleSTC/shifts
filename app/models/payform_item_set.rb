class PayformItemSet < ActiveRecord::Base

  belongs_to :payform  
  
  delegate :department, :to => :category
  delegate :user, :to => :payform

end

def self.build(dept, usr, date)
  period_date = PayformItemSet.default_period_date(date, dept)
  PayformItemSet.find(:first, :conditions => {:user_id => usr, :department_id => dept, :date => period_date}) ||
  PayformItemSet.create(:user_id => usr, :department_id => dept, :date => period_date)
end