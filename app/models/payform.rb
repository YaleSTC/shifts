class Payform < ActiveRecord::Base

  has_many :payform_items
  belongs_to :payform_set
  belongs_to :department
  belongs_to :user
  belongs_to :approved_by, :class_name => "User", :foreign_key => "approved_by_id"

  validates_presence_of :department_id, :user_id, :date
  validates_presence_of :submitted, :if => :approved
  validates_presence_of :approved,  :if => :printed

  named_scope :unsubmitted, {:conditions => ["submitted IS ?", nil] }
  named_scope :unapproved,  {:conditions => ["submitted IS NOT ? AND approved IS ?", nil, nil] }
  named_scope :unprinted,   {:conditions => ["approved IS NOT ? AND printed IS ?", nil, nil] }
  named_scope :printed,     {:conditions => ["printed IS NOT ?", nil] }


  def status
    self.printed ? 'printed' : self.approved ? 'approved' : self.submitted ? 'submitted' : 'unsubmitted'
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
    if dept.department_config.monthly
      given_date_day = given_date.mday
      if dept.department_config.end_of_month
        dept.department_config.day = given_date.end_of_month
      end
      if dept.department_config.day < given_date_day
        given_date = given_date + 1.month
      end
    else
      given_date_day = given_date.wday
      if dept.department_config.day < given_date_day
        given_date = given_date + 1.week
      end
    end
    (given_date - given_date_day.days + dept.department_config.day.days).to_date
  end

  def hours
    payform_items.select{|p| p.active}.map{|i| i.hours}.sum
  end

  def start_date
    subtract = (department.department_config.monthly ? 1.month : 1.week)
    date - subtract + 1.day
  end


  protected

  def validate
    if (approved or printed) and !submitted
      errors.add("Cannot approve or print unsubmitted payform, so the submitted field")
    end
    if printed and !approved
      errors.add("Cannot print unapproved payform, so the approved field")
    end
  end

end
