class RepeatingEvent < ActiveRecord::Base
  belongs_to :calendar
  has_many :time_slots
  has_many :shifts

  #This method takes a repeating event, destroys all future timeslots/shifts associated with it,
  #orphans all previous timeslots/shifts associated with it, and destroys the repeating event
  def self.destroy_self_and_future(repeating_event)
    if repeating_event.has_time_slots?
        TimeSlot.delete_all("repeating_event_id = \"#{repeating_event.id}\" AND end > \"#{Time.now.to_s(:sql)}\"")
        TimeSlot.update_all("repeating_event_id = NULL", "repeating_event_id = \"#{repeating_event.id}\"")
      else
        Shift.delete_all("repeating_event_id = \"#{repeating_event.id}\" AND end > \"#{Time.now.to_s(:sql)}\"")
        Shift.update_all("repeating_event_id = NULL", "repeating_event_id = \"#{repeating_event.id}\"")
    end
    repeating_event.destroy
  end

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
