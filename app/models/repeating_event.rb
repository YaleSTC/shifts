class RepeatingEvent < ActiveRecord::Base
  belongs_to :calendar
  has_many :time_slots
  has_many :shifts

  def self.make_future(end_date, day, time_slot_or_shift)
    seed = time_slot_or_shift.clone
    while seed.end <= end_date
      seed.start = seed.start.next(day)
      seed.end = seed.end.next(day)
      seed.save! if seed.end <= end_date
      seed = seed.clone
    end
  end

  def days
    self.days_of_week.split(",").collect{|d| d.to_i.day_of_week} if self.days_of_week
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
