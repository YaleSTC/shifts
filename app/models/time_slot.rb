class TimeSlot < ActiveRecord::Base
#  default_scope :conditions => {:active => true}
  belongs_to :location
  belongs_to :calendar
  belongs_to :repeating_event
  has_many :shifts, :through => :location
  before_save :set_active

  validates_presence_of :start, :end, :location_id
  validate :start_less_than_end

  named_scope :in_locations, lambda {|loc_array| {:conditions => { :location_id => loc_array }}}
  named_scope :in_location, lambda {|location| {:conditions => { :location_id => location }}}
  named_scope :on_days, lambda {|start_day, end_day| { :conditions => ['"start" >= ? and "start" < ?', start_day.beginning_of_day.utc, end_day.end_of_day.utc]}}
  named_scope :on_day, lambda {|day| { :conditions => ['"start" >= ? and "start" < ?', day.beginning_of_day.utc, day.end_of_day.utc]}}
  named_scope :after_now, lambda {{:conditions => ['"end" >= ?', Time.now.utc ]}}


  #This method creates the multitude of shifts required for repeating_events to work
  #in order to work efficiently, it makes a few GIANT sql insert calls
  def self.make_future(end_date, cal_id, r_e_id, days, loc_ids, start_time, end_time, active, wipe)
    #We need several inner arrays with one big outer one, b/c sqlite freaks out if the sql insert call is too big
    outer_make = []
    inner_make = []
    outer_test = []
    inner_test = []
    diff = end_time - start_time
    #Take each location and day and build an array containing the pieces of the sql query
    loc_ids.each do |loc_id|
      days.each do |day|
        seed_start_time = start_time
        seed_end_time = end_time
        while seed_end_time <= end_date
          seed_start_time = seed_start_time.next(day)
          seed_end_time = seed_start_time + diff
          inner_test.push "(location_id = '#{loc_id}' AND active = '#{true.to_sqlness}' AND start <= '#{seed_end_time.utc.to_s(:sql)}' AND end >= '#{seed_start_time.utc.to_s(:sql)}')"
          inner_make.push "'#{loc_id}', '#{cal_id}', '#{r_e_id}', '#{seed_start_time.utc.to_s(:sql)}', '#{seed_end_time.utc.to_s(:sql)}', '#{Time.now.utc.to_s(:sql)}', '#{Time.now.utc.to_s(:sql)}', '#{active.to_sqlness}'"
          #Once the array becomes big enough that the sql call will insert 450 rows, start over w/ a new array
          #without this bit, sqlite freaks out if you are inserting a larger number of rows. Might need to be changed
          #for other databases (it can probably be higher for other ones I think, which would result in faster execution)
        if inner_make.length > 450
          outer_make.push inner_make
          inner_make = []
          outer_test.push inner_test
          inner_test = []
        end
        end
        #handle leftovers or the case where there are less than 450 rows to be inserted
      outer_make.push inner_make
      outer_test.push inner_test
      end
    end
    #for each set of rows to be inserted, insert them, all within a transaction for speed's sake
    if wipe
        outer_test.each do |s|
          TimeSlot.delete_all(s.join(" OR "))
        end
        outer_make.each do |s|
          sql = "INSERT INTO time_slots ('location_id', 'calendar_id', 'repeating_event_id', 'start', 'end', 'created_at', 'updated_at', 'active') SELECT #{s.join(" UNION ALL SELECT ")};"
          ActiveRecord::Base.connection.execute sql
        end
      return false
    else
      out = []
        outer_test.each do |s|
          out += TimeSlot.find(:all, :conditions => [s.join(" OR ")])
        end
      if out.empty? || !active
          outer_make.each do |s|
            sql = "INSERT INTO time_slots ('location_id', 'calendar_id', 'repeating_event_id', 'start', 'end', 'created_at', 'updated_at', 'active') SELECT #{s.join(" UNION ALL SELECT ")};"
            ActiveRecord::Base.connection.execute sql
          end
        return false
      end
      return out.collect{|t| "The timeslot "+t.to_message_name+" conflicts. Use wipe to fix."}.join(",")
    end
  end

  def self.check_for_conflicts(time_slots)
    if time_slots.empty?
      ""
    else
      TimeSlot.find(:all, :conditions => [time_slots.collect{|t| "(location_id = '#{t.location_id}' AND active = '#{true.to_sqlness}' AND start <= '#{t.end.utc.to_s(:sql)}' AND end >= '#{t.start.utc.to_s(:sql)}')"}.join(" OR ")]).collect{|t| "The timeslot "+t.to_message_name+" conflicts. Use wipe to fix."}.join(",")
    end
  end

  def duration
    self.end-self.start
  end

  def to_s
    self.location.short_name + ', ' + self.start.to_s(:am_pm_long) + " - " + self.end.to_s(:am_pm_long)
  end

  def to_message_name
    "in "+self.location.short_name + ' from ' + self.start.to_s(:am_pm_long_no_comma) + " to " + self.end.to_s(:am_pm_long_no_comma)
  end

  private

  def set_active
    self.active = self.calendar.active
  end

  def start_less_than_end
    errors.add(:start, "must be earlier than end time") if (self.end <= start)
  end
end
