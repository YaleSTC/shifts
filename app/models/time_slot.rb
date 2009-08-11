class TimeSlot < ActiveRecord::Base
  belongs_to :location
  belongs_to :calendar
  belongs_to :repeating_event
  has_many :shifts, :through => :location

  validates_presence_of :start, :end, :location_id
  validate :start_less_than_end

  named_scope :in_locations, lambda {|loc_array| {:conditions => { :location_id => loc_array }}}
  named_scope :in_location, lambda {|location| {:conditions => { :location_id => location }}}
  named_scope :on_days, lambda {|start_day, end_day| { :conditions => ['"start" >= ? and "start" < ?', start_day.beginning_of_day.utc, end_day.end_of_day.utc]}}
  named_scope :on_day, lambda {|day| { :conditions => ['"start" >= ? and "start" < ?', day.beginning_of_day.utc, day.end_of_day.utc]}}
  named_scope :after_now, lambda {{:conditions => ['"end" >= ?', Time.now.utc ]}}


  #This method creates the multitude of shifts required for repeating_events to work
  #in order to work efficiently, it makes a few GIANT sql insert calls
  def self.make_future(end_date, cal_id, r_e_id, days, loc_ids, start_time, end_time)
    #We need several inner arrays with one big outer one, b/c sqlite freaks out if the sql insert call is too big
    outer = []
    inner = []
    #Take each location and day and build an array containing the pieces of the sql query
    loc_ids.each do |loc_id|
      days.each do |day|
        seed_start_time = start_time
        seed_end_time = end_time
        while seed_end_time <= end_date
          seed_start_time = seed_start_time.next(day)
          seed_end_time = seed_end_time.next(day)
          inner.push "\"#{loc_id}\", \"#{cal_id}\", \"#{r_e_id}\", \"#{seed_start_time.to_s(:sql)}\", \"#{seed_end_time.to_s(:sql)}\", \"#{Time.now.to_s(:sql)}\", \"#{Time.now.to_s(:sql)}\""
          #Once the array becomes big enough that the sql call will insert 450 rows, start over w/ a new array
          #without this bit, sqlite freaks out if you are inserting a larger number of rows. Might need to be changed
          #for other databases (it can probably be higher for other ones I think, which would result in faster execution)
          if inner.length > 450
            outer.push inner
            inner = []
          end
        end
        #handle leftovers or the case where there are less than 450 rows to be inserted
        outer.push inner
      end
    end
    #for each set of rows to be inserted, insert them, all within a transaction for speed's sake
    ActiveRecord::Base.transaction do
      outer.each do |s|
        sql = "INSERT INTO time_slots ('location_id', 'calendar_id', 'repeating_event_id', 'start', 'end', 'created_at', 'updated_at') SELECT #{s.join(" UNION ALL SELECT ")};"
        ActiveRecord::Base.connection.execute sql
      end
    end
  end

  def duration
    self.end-self.start
  end

  def to_s
    self.location.short_name + ', ' + self.start.to_s(:am_pm_long) + " - " + self.end.to_s(:am_pm_long)
  end

  private

  def start_less_than_end
    errors.add(:start, "must be earlier than end time") if (self.end <= start)
  end
end
