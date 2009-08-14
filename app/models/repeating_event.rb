class RepeatingEvent < ActiveRecord::Base
  belongs_to :calendar
  has_many :time_slots
  has_many :shifts
  validate :loc_ids_present
  validate :days_of_week_present
  validate :user_id_present, :if => Proc.new{|repeating_event| repeating_event.has_shifts?}
  validate :start_date_less_than_end_date
  before_save :set_start_times
  before_save :adjust_for_past_event
  before_save :adjust_for_multi_day


  #This method takes a repeating event, destroys all future timeslots/shifts associated with it,
  #orphans all previous timeslots/shifts associated with it, and destroys the repeating event
  def self.destroy_self_and_future(repeating_event)
    if repeating_event.has_time_slots?
        TimeSlot.delete_all("repeating_event_id = '#{repeating_event.id}' AND end > '#{Time.now.utc.to_s(:sql)}'")
        TimeSlot.update_all("repeating_event_id = NULL", "repeating_event_id = '#{repeating_event.id}'")
      else
        Shift.delete_all("repeating_event_id = '#{repeating_event.id}' AND end > '#{Time.now.utc.to_s(:sql)}'")
        Shift.update_all("repeating_event_id = NULL", "repeating_event_id = '#{repeating_event.id}'")
    end
    repeating_event.destroy
  end

  def make_future(wipe)
    if self.has_time_slots?
      TimeSlot.make_future(self.end_date, self.calendar.id, self.id, self.days_int, self.location_ids, self.start_time, self.end_time, self.calendar.active, wipe)
    else
      Shift.make_future(self.end_date, self.calendar.id, self.id, self.days_int, self.location_ids.first, self.start_time, self.end_time, self.user_id, Location.find(self.location_ids.first).loc_group.department.id, self.calendar.active, wipe)
    end
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

#  def check_make_future
#    if failed = self.make_future
#      failed.each do |f|
#        errors.add_to_base("#{f.to_s} conflicts. Apply with wipe to fix this.")
#      end
#      self.destroy
#    end
#  end

  def days_of_week_present
    errors.add_to_base("You must select at least one day of the week!") unless days_of_week
  end

  def loc_ids_present
    errors.add_to_base("You must select at least one location!") unless loc_ids
  end

  def user_id_present
    errors.add_to_base("User can't be blank!") unless self.user_id
  end

  def start_date_less_than_end_date
    errors.add(:start_date, "must be earlier than end date") if (self.end_date < self.start_date)
  end

  def set_start_times
    self.start_time = self.start_time.change(:day => self.start_date.day, :month => self.start_date.month, :year => self.start_date.year)
      self.end_time = self.end_time.change(:day => self.start_date.day, :month => self.start_date.month, :year => self.start_date.year)
  end

  def adjust_for_multi_day
    self.end_time += 1.days if self.end_time < self.start_time
  end

  def adjust_for_past_event
    if self.start_time <= Time.now
      self.start_time = self.start_time.change(:day => Date.today.day, :month => Date.today.month, :year => Date.today.year)
      self.end_time = self.end_time.change(:day => Date.today.day, :month => Date.today.month, :year => Date.today.year)
    end
    if self.start_time <= Time.now
      self.start_time = self.start_time.change(:day => Date.tomorrow.day, :month => Date.tomorrow.month, :year => Date.tomorrow.year)
      self.end_time = self.end_time.change(:day => Date.tomorrow.day, :month => Date.tomorrow.month, :year => Date.tomorrow.year)
    end
  end

end
