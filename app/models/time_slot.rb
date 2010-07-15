class TimeSlot < ActiveRecord::Base
  belongs_to :location
  belongs_to :calendar
  belongs_to :repeating_event
  has_many :shifts, :through => :location
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

  named_scope :active, lambda {{:conditions => {:active => true}}}
  named_scope :in_locations, lambda {|loc_array| {:conditions => { :location_id => loc_array }}}
  named_scope :in_location, lambda {|location| {:conditions => { :location_id => location }}}
  named_scope :in_calendars, lambda {|calendar_array| {:conditions => { :calendar_id => calendar_array }}}
  named_scope :on_days, lambda {|start_day, end_day| { :conditions => ["#{:start.to_sql_column} >= #{start_day.beginning_of_day.utc.to_sql} and #{:start.to_sql_column} < #{end_day.end_of_day.utc.to_sql}"]}}
  named_scope :on_day, lambda {|day| { :conditions => ["#{:end.to_sql_column} >= #{day.beginning_of_day.utc.to_sql} AND #{:start.to_sql_column} < #{day.end_of_day.utc.to_sql}"]}}
  named_scope :on_48h, lambda {|day| { :conditions => ["#{:end.to_sql_column} >= #{day.beginning_of_day.utc.to_sql} AND #{:start.to_sql_column} < #{(day.end_of_day + 1.day).utc.to_sql}"]}}
  named_scope :overlaps, lambda {|start, stop| { :conditions => ["#{:end.to_sql_column} > #{start.utc.to_sql} and #{:start.to_sql_column} < #{stop.utc.to_sql}"]}}
  named_scope :after_now, lambda {{:conditions => ["#{:end} >= #{Time.now.utc.to_sql}"]}}


  #This method creates the multitude of shifts required for repeating_events to work
  #in order to work efficiently, it makes a few GIANT sql insert calls -Mike
  def self.make_future(end_date, cal_id, r_e_id, days, loc_ids, start_time, end_time, active, wipe)
    #We need several inner arrays with one big outer one, b/c sqlite freaks out
    #if the sql insert call is too big. The "make" arrays are then used for making
    #the timeslots, and the "test" for finding conflicts.
    outer_make = []
    inner_make = []
    outer_test = []
    inner_test = []
    diff = end_time - start_time
    #Take each location and day and build an arrays containing the pieces of the sql queries
    loc_ids.each do |loc_id|
      days.each do |day|
        seed_start_time = (start_time.wday == day ? start_time : start_time.next(day))
        seed_end_time = seed_start_time+diff
        while seed_end_time <= (end_date + 1.day)
          if active
            inner_test.push "(#{:location_id.to_sql_column} = #{loc_id.to_sql} AND #{:active.to_sql_column} = #{true.to_sql} AND #{:start.to_sql_column} <= #{seed_end_time.utc.to_sql} AND #{:end.to_sql_column} >= #{seed_start_time.utc.to_sql})"
          else
            inner_test.push "(#{:location_id.to_sql_column} = #{loc_id.to_sql} AND #{:calendar_id.to_sql_column} = #{cal_id.to_sql} AND #{:start.to_sql_column} <= #{seed_end_time.utc.to_sql} AND #{:end.to_sql_column} >= #{seed_start_time.utc.to_sql})"
          end
          inner_make.push "#{loc_id.to_sql}, #{cal_id.to_sql}, #{r_e_id.to_sql}, #{seed_start_time.utc.to_sql}, #{seed_end_time.utc.to_sql}, #{Time.now.utc.to_sql}, #{Time.now.utc.to_sql}, #{active.to_sql}"
          #Once the array becomes big enough that the sql call will insert 450 rows, start over w/ a new array
          #without this bit, sqlite freaks out if you are inserting a larger number of rows. Might need to be changed
          #for other databases (it can probably be higher for other ones I think, which would result in faster execution)
          if inner_make.length > 450
            outer_make.push inner_make
            inner_make = []
            outer_test.push inner_test
            inner_test = []
          end
          seed_start_time = seed_start_time.next(day)
          seed_end_time = seed_start_time + diff
        end
        #handle leftovers or the case where there are less than 450 rows to be inserted
      end
    end
      outer_make.push inner_make unless inner_make.empty?
      outer_test.push inner_test unless inner_test.empty?
    #Look for conflicts, delete them if wipe is on, and either complain about
    #conflicts or make the new timeslots
    if wipe
        outer_test.each do |s|
          TimeSlot.delete_all(s.join(" OR "))
        end
        outer_make.each do |s|
          sql = "INSERT INTO time_slots (#{:location_id.to_sql_column}, #{:calendar_id.to_sql_column}, #{:repeating_event_id.to_sql_column}, #{:start.to_sql_column}, #{:end.to_sql_column}, #{:created_at.to_sql_column}, #{:updated_at.to_sql_column}, #{:active.to_sql_column}) SELECT #{s.join(" UNION ALL SELECT ")};"
          ActiveRecord::Base.connection.execute sql
        end
      return false
    else
      out = []
        outer_test.each do |s|
          out += TimeSlot.find(:all, :conditions => [s.join(" OR ")])
        end
      if out.empty?
          outer_make.each do |s|
            sql = "INSERT INTO time_slots (#{:location_id.to_sql_column}, #{:calendar_id.to_sql_column}, #{:repeating_event_id.to_sql_column}, #{:start.to_sql_column}, #{:end.to_sql_column}, #{:created_at.to_sql_column}, #{:updated_at.to_sql_column}, #{:active.to_sql_column}) SELECT #{s.join(" UNION ALL SELECT ")};"
            ActiveRecord::Base.connection.execute sql
          end
        return false
      end
      return out.collect{|t| "The timeslot "+t.to_message_name+" conflicts. Use wipe to fix."}.join(",")
    end
  end


  #Used for activating calendars, check/wipe conflicts -Mike
  def self.check_for_conflicts(time_slots, wipe)
    #big_array is just an array of arrays, the inner arrays being less than 450
    #elements so sql doesn't freak
    big_array = []
    while time_slots && !time_slots.empty? do
      big_array.push time_slots[0..450]
      time_slots = time_slots[451..time_slots.length]
    end
    if big_array.empty?
      ""
    elsif wipe
      big_array.each do |t_slots|
        TimeSlot.delete_all([t_slots.collect{|t| "(location_id = #{t.location_id.to_sql} AND active = #{true.to_sql} AND start <= #{t.end.utc.to_sql} AND end >= #{t.start.utc.to_sql})"}.join(" OR ")])
      end
      return ""
    else
      out=big_array.collect do |t_slots|
        TimeSlot.find(:all, :conditions => [t_slots.collect{|t| "(location_id = #{t.location_id.to_sql} AND active = #{true.to_sql} AND start <= #{t.end.utc.to_sql} AND end >= #{t.start.utc.to_sql})"}.join(" OR ")]).collect{|t| "The timeslot "+t.to_message_name+"."}.join(",")
      end
      return out.join(",")
    end
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

  def join_date_and_time
    self.start ||= self.start_date.to_date.to_time + self.start_time.seconds_since_midnight
    self.end ||= self.end_date.to_date.to_time + self.end_time.seconds_since_midnight
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
      c = TimeSlot.count(:all, :conditions => ["#{:start.to_sql_column} < #{self.end.to_sql} AND #{:end.to_sql_column} > #{self.start.to_sql} AND #{:location_id.to_sql_column} = #{self.location.to_sql} AND #{:active.to_sql_column} = #{true.to_sql} #{dont_conflict_with_self}"])
    else
      c = TimeSlot.count(:all, :conditions => ["#{:start.to_sql_column} < #{self.end.to_sql} AND #{:end.to_sql_column} > #{self.start.to_sql} AND #{:location_id.to_sql_column} = #{self.location.to_sql} AND #{:calendar_id.to_sql_column} = #{self.calendar.to_sql} #{dont_conflict_with_self}"])
    end
    unless c.zero?
      errors.add_to_base("There is a conflicting timeslot.")
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
      errors.add_to_base("Time slot start and end times must be within the range of the calendar.") if self.start < self.calendar.start_date || self.end > self.calendar.end_date
    end
  end
end

