class RepeatingEvent < ActiveRecord::Base
  belongs_to :calendar
  has_many :time_slots
  has_many :shifts
  validate :loc_ids_present
  validate :days_of_week_present
  validates_presence_of :user, :if => Proc.new{|repeating_event| repeating_event.has_shifts?}
  validate_on_create :not_in_the_past
  validate :start_date_less_than_end_date
  validate :start_time_less_than_end_time


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

  def location_ids=(ids)
    self.loc_ids=ids.join(",") if ids
  end

  def location_ids
    self.loc_ids.split(",").collect{|d| d.to_i} if loc_ids
  end

  def days_int
    self.days_of_week.split(",").collect{|d| d.to_i} if days_of_week
  end

  def days=(array_of_days)
    self.days_of_week = array_of_days.join(',') if array_of_days
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

  private

  def days_of_week_present
    errors.add_to_base("You must select at least one day of the week!") unless days_of_week
  end

  def loc_ids_present
    errors.add_to_base("You must select at least one location!") unless loc_ids
  end

  def not_in_the_past
    errors.add_to_base("Can't create a repeating event that starts in the past!") if self.start_time <= Time.now
  end

  def start_date_less_than_end_date
    errors.add(:start_date, "must be earlier than end date") if (self.end_date < self.start_date)
  end

  def start_time_less_than_end_time
    errors.add(:start_time, "must be earlier than end time") if (self.end_time < self.start_time)
  end

end
