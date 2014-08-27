# == Schema Information
#
# Table name: department_configs
#
#  id                   :integer          not null, primary key
#  department_id        :integer
#  schedule_start       :integer
#  schedule_end         :integer
#  time_increment       :integer
#  grace_period         :integer
#  auto_remind          :boolean          default(TRUE)
#  auto_warn            :boolean          default(TRUE)
#  mailer_address       :string(255)
#  monthly              :boolean          default(FALSE)
#  end_of_month         :boolean          default(FALSE)
#  day                  :integer          default(6)
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#  weekend_shifts       :boolean
#  unscheduled_shifts   :boolean
#  printed_message      :text
#  reminder_message     :text
#  warning_message      :text
#  warning_weeks        :integer
#  description_min      :integer
#  reason_min           :integer
#  can_take_passed_sub  :boolean          default(TRUE)
#  stats_mailer_address :string(255)
#  stale_shift          :boolean          default(TRUE)
#  payform_time_limit   :integer
#  admin_round_option   :integer          default(15)
#  early_signin         :integer          default(60)
#  task_leniency        :integer          default(60)
#  search_engine_name   :string(255)      default("Google")
#  search_engine_url    :string(255)      default("http://www.google.com/search?q=")
#  default_category_id  :integer
#

class DepartmentConfig < ActiveRecord::Base
  belongs_to :department

  validates_presence_of :department_id, :printed_message, :reminder_message, :warning_message
  validates_uniqueness_of :department_id
  validates_numericality_of :time_increment, :grace_period, :schedule_start, :schedule_end, :description_min, :reason_min, :warning_weeks, :admin_round_option, :early_signin, :task_leniency
  validate :increment_factor_of_60

  PAYFORM_PERIOD = [
    ["Weekly",  false],
    ["Monthly", true ]
  ]

  LAST_DAY_SELECT = [
    ["Last day of month", Time.now.end_of_month.day]
  ]

  WEEK_DAY_SELECT = [
    [Date::DAYNAMES[0], 0],
    [Date::DAYNAMES[1], 1],
    [Date::DAYNAMES[2], 2],
    [Date::DAYNAMES[3], 3],
    [Date::DAYNAMES[4], 4],
    [Date::DAYNAMES[5], 5],
    [Date::DAYNAMES[6], 6]
  ]

  def calibrate_time
    #allow the schedule for a day to end at, say, 2:00am
    if self
      self.schedule_end += 24*60 if self.schedule_end <= self.schedule_start
      self.save
    end
  end

  # methods for use in the schedule view
  def blocks_per_hour
    60 / self.time_increment
  end

  def blocks_per_day
    ((self.schedule_end - self.schedule_start) / self.time_increment).to_i
  end

  def block_length
    self.time_increment * 60 #seconds
  end

  def default_category
    Category.find(self.default_category_id) || Category.active.built_in.first
  end

protected

  def increment_factor_of_60
    errors.add(:time_increment, "must divide evenly into 60") unless 60 % self.time_increment == 0
  end

end
