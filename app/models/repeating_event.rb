class RepeatingEvent < ActiveRecord::Base
  belongs_to :calendar
  has_many :time_slots
  has_many :shifts
  validate :loc_ids_present
  validate :days_of_week_present
  validate :user_id_present
  validate :start_date_less_than_end_date
  validate :is_within_calendar
  before_save :set_start_times
  before_save :adjust_for_past_event
  before_save :adjust_for_multi_day


  #This method takes a repeating event, destroys all future timeslots/shifts associated with it,
  #orphans all previous timeslots/shifts associated with it, and destroys the repeating event
  def self.destroy_self_and_future(repeating_event, time=false)
    should_update = !time
    time = Time.now unless time

    TimeSlot.delete_all(["repeating_event_id = ? AND end > ? }", repeating_event.id, time.utc])
    Shift.mass_delete_with_dependencies(Shift.where("repeating_event_id = ? AND end > ?", repeating_event.id, time.utc))

    if should_update
      TimeSlot.where(repeating_event_id: repeating_event.id).update_all(repeating_event_id: nil)
      Shift.where(repeating_event_id: repeating_event.id).update_all(repeating_event_id: nil)
      repeating_event.destroy
    end
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

  def locations
    self.loc_ids.split(",").collect{|d| Location.find(d.to_i)} if loc_ids
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



  # ideally this might be made an overload of the 'new' action,
  # but for now, this will do
  # creates a new repeating event from an existing event. the repeating
  # event will span the entire calendar, and wipe all conflicts.
  def self.create_from_existing_event( event )
    if event.calendar.default?
      return false #cannot make repeating events on the default calendar
    else
      repeating_event = RepeatingEvent.new

      if event.class == Shift
        repeating_event.is_set_of_timeslots = false
        repeating_event.user_id = event.user.id
      elsif event.class == TimeSlot
        repeating_event.is_set_of_timeslots = true
      else
        return false #we can't make a repeating event out of anything else
      end

      #this will span the whole calendar
      repeating_event.calendar = event.calendar
      repeating_event.start_date = event.calendar.start_date
      repeating_event.end_date = event.calendar.end_date
      repeating_event.start_time = event.start
      repeating_event.end_time = event.end

      #get location from event
      repeating_event.loc_ids = event.location_id.to_s

      #repeat weekly
      repeating_event.days_of_week = event.start.wday.to_s

      ActiveRecord::Base.transaction do
        event.destroy
        repeating_event.save!
        failed = repeating_event.make_future(true) #wipe conflicts
        raise failed if failed
      end

      return true
    end
  end




  private

#  def check_make_future
#    if failed = self.make_future
#      failed.each do |f|
#        errors.add(:base, "#{f.to_s} conflicts. Apply with wipe to fix this.")
#      end
#      self.destroy
#    end
#  end

  def days_of_week_present
    errors.add(:base, "You must select at least one day of the week.") unless days_of_week
  end

  def loc_ids_present
    errors.add(:base, "You must select at least one location.") unless loc_ids
  end

  def user_id_present
    errors.add(:base, "Please select a user.") unless (self.user_id && self.user_id!=0 && !self.user_id.nil?) || self.is_set_of_timeslots
  end

  def start_date_less_than_end_date
    errors.add(:start_date, "must be earlier than end date") if (self.end_date < self.start_date)
  end

  def set_start_times
    self.start_time = self.start_date.to_time + self.start_time.seconds_since_midnight
    self.end_time = self.start_date.to_time + self.end_time.seconds_since_midnight
#self.start_time.change(:day => self.start_date.day, :month => self.start_date.month, :year => self.start_date.year)
 #     self.end_time = self.end_time.change(:day => self.start_date.day, :month => self.start_date.month, :year => self.start_date.year)
  end

  def adjust_for_multi_day
    self.end_time += 1.days if self.end_time < self.start_time
  end

  def is_within_calendar
    unless self.calendar.default
      errors.add(:base, "Repeating event start and end dates must be within the range of the calendar.") if self.start_date < self.calendar.start_date || self.end_date > self.calendar.end_date
    end
  end

  def adjust_for_past_event
    if self.start_time <= Time.now
      self.start_time = self.start_time.change(day: Date.today.day, month: Date.today.month, year: Date.today.year)
      self.end_time = self.end_time.change(day: Date.today.day, month: Date.today.month, year: Date.today.year)
    end
    if self.start_time <= Time.now
      self.start_time = self.start_time.change(day: Date.tomorrow.day, month: Date.tomorrow.month, year: Date.tomorrow.year)
      self.end_time = self.end_time.change(day: Date.tomorrow.day, month: Date.tomorrow.month, year: Date.tomorrow.year)
    end
  end


end

