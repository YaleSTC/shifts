class Payform < ActiveRecord::Base

  has_many :payform_items
  #has_and_belongs_to_many :payform_items
  belongs_to :payform_set #group of printed payforms
  belongs_to :department
  belongs_to :user
  belongs_to :approved_by, :class_name => "User", :foreign_key => "approved_by_id"

  attr_accessor :start_date
  attr_accessor :end_date

  validates_presence_of :department_id, :user_id, :date
  validates_presence_of :submitted, :if => :approved
  validates_presence_of :approved,  :if => :printed
  validates :date, :uniqueness => {:scope => [:user_id, :department_id, :monthly]}

  scope :unsubmitted, {:conditions => ["#{:submitted.to_sql_column} IS #{nil.to_sql}"] }
  scope :unapproved,  {:conditions => ["#{:submitted.to_sql_column} IS NOT #{nil.to_sql} AND approved IS #{nil.to_sql}"] }
  scope :skipped,     {:conditions => ["#{:skipped.to_sql_column} IS NOT #{nil.to_sql}"] }
  scope :unskipped,   {:conditions => ["#{:skipped.to_sql_column} IS #{nil.to_sql}"] }
  scope :unprinted,   {:conditions => ["#{:approved.to_sql_column} IS NOT #{nil.to_sql} AND #{:printed.to_sql_column} IS #{nil.to_sql}", nil, nil] }
  scope :printed,     {:conditions => ["#{:printed.to_sql_column} IS NOT #{nil.to_sql}"] }

  before_create :set_payrate


  def self.export_payform(options = {})
    CSV.generate(options) do |csv|
      csv << ["End Date", "First Name", "Last Name", "User ID", "Employee ID", "Payrate", "Hours", "Billing Code"]
      sorted_payforms = all.delete_if{|payform| payform.hours == 0}\
        .sort_by{|payform| payform.user.last_name}\
        .sort_by{|payform| payform.date}
      sorted_payforms.each do |payform|
        user = User.find(payform.user_id)
        grouped_items = payform.payform_items.select{|p| p.active}.group_by{|p| p.category.billing_code}
        grouped_items.each do |billing_code, payform_items|
          csv << [payform.date, user.first_name, user.last_name, user.login, user.employee_id, payform.payrate, PayformItem.rounded_hours(payform_items), billing_code]
        end
      end
    end
  end


  def status
    self.printed ? 'printed' : self.approved ? 'approved' : self.submitted ? 'submitted' : 'unsubmitted'
  end

  #CUSTOM URL -- STILL REQUIRES ID AT FRONT, BUT LOOKS FRIENDLIER
  def to_param
    "#{id}-#{date}"
  end

  def self.build(dept, usr, given_date)
    period_date = Payform.default_period_date(given_date, dept)
    begin
      Payform.where(:user_id => usr.id, :department_id => dept.id, :date => period_date).first() ||
      Payform.create!(:user_id => usr.id, :department_id => dept.id, :date => period_date)
    rescue ActiveRecord::RecordInvalid
      Payform.where(:user_id => usr.id, :department_id => dept.id, :date => period_date).first()
    end
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

  # Total payform hours rounded according to department rounding option.
  def hours
    raw_hours = payform_items.select{|p| p.active}.map{|i| i.hours}.sum
    rounded_hours = ((raw_hours.to_f * 60 / department.department_config.admin_round_option.to_f).round * (department.department_config.admin_round_option.to_f / 60))
    sprintf( "%0.02f", rounded_hours).to_f
  end

  def hours_minutes_string
    hours = self.hours
    return "0:00" if hours.nil? || hours == 0
    hrs_i = hours.to_i
    hrs_f = hours.to_f
    units = hrs_f % hrs_i
    units = ((units / 5) * 300)
    hrs_s = "#{hours.to_i.to_s}:#{units.to_i.to_s}"
    hrs_s += "0" if hrs_s =~ /:0$/
    return hrs_s
  end

  def start_date
    subtract = (department.department_config.monthly ? 1.month : 1.week)
    date - subtract + 1.day
  end

  protected

  def validate
    if (approved or printed) and !submitted
      errors.add("Cannot approve or print unsubmitted payform.")
    end
    if printed and !approved
      errors.add("Cannot print unapproved payform.")
    end
  end

  def set_payrate
    self.payrate = user.payrate(department)
  end
end
