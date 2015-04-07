class TimeSlot < ActiveRecord::Base
  belongs_to :location
  belongs_to :calendar
  belongs_to :repeating_event
  has_many :shifts, through: :location
  before_save :set_active
  before_validation :adjust_for_multi_day
  before_update :disassociate_from_repeating_event

  validates_presence_of :start, :end, :location_id
  validate :start_less_than_end
  validate :is_within_calendar
  validate :no_concurrent_timeslots

  attr_accessor :start_date
  attr_accessor :start_time
  attr_accessor :end_date
  attr_accessor :end_time

  scope :active, -> { where(active: true) }
  scope :in_locations, ->(loc_array){ where(location_id: loc_array ) }
  scope :in_location, ->(location){ where(location_id: location) }
  scope :in_calendars, ->(calendar_array){ where(calendar_id: calendar_array) }

  scope :on_days, ->(start_day, end_day){ where("start >= ? and start < ?", start_day.beginning_of_day.utc, end_day.end_of_day.utc) }
  scope :on_day, ->(day){ where("end >= ? AND start < ?", day.beginning_of_day.utc, day.end_of_day.utc) }
  scope :on_48h, ->(day){ where("end >= ? AND start < ?", day.beginning_of_day.utc, (day.end_of_day + 1.day).utc) }
  scope :overlaps, ->(start, stop){ where("end > ? and start < ?", start.utc, stop.utc) }
  scope :ordered_by_start, order('start')
  scope :after_now, -> { where("end >= ?", Time.now.utc) }



  def self.make_future(event, wipe)
    dates = event.dates_array
    cal = event.calendar
    if cal.active
      time_slot_scope = TimeSlot.active
    else
      time_slot_scope = TimeSlot.where(calendar_id: cal.id)
    end
    loc_ids = event.location_ids
    table = TimeSlot.arel_table
    time_slots_all = Array.new
    duration = event.end_time - event.start_time
    conflict_all = nil
    loc_ids.each do |loc_id|
      dates.each do |date|
        start_time_on_date = date.to_time + event.start_time.seconds_since_midnight
        end_time_on_date = start_time_on_date + duration
        time_slots_all << TimeSlot.new(location_id: loc_id, calendar_id: cal.id, repeating_event_id: event.id, start: start_time_on_date, end: end_time_on_date, active: cal.active)
      end
    end
    conflict_msg = TimeSlot.check_for_conflicts(time_slots_all, wipe, time_slot_scope)
    if conflict_msg.empty?
      if time_slots_all.map(&:valid?).all?
        TimeSlot.import time_slots_all
        return false
      else
        invalid_time_slots = time_slots_all.select{|t| !t.valid?}
        return invalid_time_slots.map{|s| "#{s.to_message_name}: #{s.errors.full_messages.join('; ')}"}.join('. ')
      end
    else
      return conflict_msg + " have conflict. Use wipe to fix."
    end
  end

  def self.check_for_conflicts(time_slots, wipe, time_slot_scope)
    return "" if time_slots.empty?
    table = TimeSlot.arel_table
    time_slots_with_conflict = Array.new
    time_slots.each_slice(450) do |tss|
      conflict_all = nil
      tss.each do |ts|
        conflict_condition = table[:location_id].eq(ts.location_id).and(table[:start].lt(ts.end)).and(table[:end].gt(ts.start))
        if conflict_all.nil?
          conflict_all = conflict_condition
        else
          conflict_all = conflict_all.or(conflict_condition)
        end
      end
      time_slots_with_conflict += time_slot_scope.where(conflict_all)
      time_slots_with_conflict.uniq!
    end
    if wipe
      TimeSlot.delete(time_slots_with_conflict.map(&:id))
    elsif !time_slots_with_conflict.empty?
      return time_slots_with_conflict.map{|t| "The timeslot #{t.to_message_name}."}.join(',')
    end
    return ""
  end

  def duration
    self.end-self.start
  end

  def to_s
    self.location.short_name + ', ' + self.start.to_s(:am_pm_long) + " - " + self.end.to_s(:am_pm_long)
  end

  def to_message_name
    "in "+self.location.short_name + ' from ' + self.start.to_s(:am_pm_long_no_comma) + " to " + self.end.to_s(:am_pm_long_no_comma) + " on " + self.calendar.name
  end

  private

  def set_active
    #self.active = self.calendar.active
    #return true
    if self.calendar.active && self.location.active
      self.active = true
    else
      self.active = false
    end
    return true
  end

  def start_less_than_end
    errors.add(:start, "must be earlier than end time.") if (self.end <= start)
  end

  def no_concurrent_timeslots
    dont_conflict_with_self = (self.new_record? ? "" : "AND id != #{self.id}")

    if self.calendar.active
      c = TimeSlot.where("start < ? AND end > ? AND location_id = ? AND active = ? #{dont_conflict_with_self}", self.end, self.start, self.location, true).count
    else
      c = TimeSlot.where("start < ? AND end > ? AND location_id = ? AND calendar_id = ? #{dont_conflict_with_self}", self.end, self.start, self.location, self.calendar.id).count
    end
    unless c == 0
      errors.add(:base, "There is a conflicting timeslot.")
    end
  end

  def disassociate_from_repeating_event
    self.repeating_event_id = nil
  end

  def adjust_for_multi_day
    self.end += 1.days if self.end <= self.start
  end

  def is_within_calendar
    unless self.calendar.default
      errors.add(:base, "Time slot start and end times must be within the range of the calendar.") if self.start.to_date < self.calendar.start_date.to_date || self.end.to_date > self.calendar.end_date.to_date
    end
  end
end

