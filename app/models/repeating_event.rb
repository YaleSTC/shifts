class RepeatingEvent < ActiveRecord::Base
  belongs_to :calendar
  has_many :time_slots
  has_many :shifts

  def days
    self.days_of_week.split(",").collect{|d| d.to_i.day_of_week} if self.days_of_week
  end

  def days_int
    self.days_of_week.split(",").collect{|d| d.to_i}
  end

  def days=(array_of_days)
    self.days_of_week = array_of_days.join(',')
  end

  def has_time_slots?
    self.is_set_of_timeslots
  end

  def has_shifts?
    !self.is_set_of_timeslots
  end

  def slot_or_shift=(thing)
    if thing=="time_slot"
      self.is_set_of_timeslots = true
    else
      self.is_set_of_timeslots = false
    end
  end

  def slot_or_shift
    if self.is_set_of_timeslots = true
      "time_slot"
    else
      "shift"
    end
  end

end
