class RepeatingEvent < ActiveRecord::Base
  belongs_to :calendar

  def days
    self.days_of_week.split(",").collect{|d| d.to_i.day_of_week}
  end

  def days=(array_of_days)
    self.days_of_week = array_of_days.join(',')
  end
end
