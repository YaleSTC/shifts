class Payform < ActiveRecord::Base

  has_many :payform_items
  belongs_to :department
  belongs_to :user
  belongs_to :approved_by, :class_name => "User", :foreign_key => "approved_by_id"
  
  validates_presence_of :department_id, :user_id

  named_scope :unsubmitted, lambda { |dept_id| {
    :conditions => ["department_id = ? AND submitted IS ?", dept_id, nil]
  }}
  named_scope :unapproved, lambda { |dept_id| {
    :conditions => ["department_id = ? AND submitted IS NOT ? AND approved IS ?", dept_id, nil, nil]
  }}
  named_scope :unprinted, lambda { |dept_id| {
    :conditions => ["department_id = ? AND approved IS NOT ? AND printed IS ?", dept_id, nil, nil]
  }}
  named_scope :printed, lambda { |dept_id| {
    :conditions => ["department_id = ? AND printed IS NOT ?", dept_id, nil]
  }}


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
  
  
  protected
  
  def validate
    if (approved or printed) and !submitted
      errors.add("Cannot approve or print unsubmitted payform, so the submitted field")
    end
    if printed and !approved
      errors.add("Cannot print unapproved payform, so the approved field")
    end
    unless user.authorized?(department.payform_configuration.payform_permission.name)
      errors.add("Payform owner is not authorized for payform department")
    end
  end

end

