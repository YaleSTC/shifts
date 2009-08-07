class TimeSlot < ActiveRecord::Base
  belongs_to :location
  belongs_to :calendar
  belongs_to :repeating_event
  has_many :shifts, :through => :location

  validates_presence_of :start, :end, :location_id
  validate :start_less_than_end

  named_scope :in_locations, lambda {|loc_array| {:conditions => { :location_id => loc_array }}}
  named_scope :on_days, lambda {|start_day, end_day| { :conditions => ['"start" >= ? and "start" < ?', start_day.beginning_of_day.utc, end_day.end_of_day.utc]}}

#TODO: This half-written method will probably never be used : (
#  def self.mass_create(slot_start, slot_end, days, locations, range_start, range_end)
#    weeklist = []
#    range_start = range_start.yesterday
#    until range_start > range_end
#      weeklist << range_start
#      range_start = Chronic("One week from now", :now=>range_start)
#    end

#    weeklist.each do |week|
#      locations.each do |loc|
#        days.each do |d|
#          t = TimeSlot.new
#          t.start = Chronic.parse("#{slot_start} on #{d}", :now => week)
#          t.end = Chronic.parse("#{slot_end} on #{d}", :now => week)
#          t.location = loc

#  end

  def self.make_future(end_date, cal_id, r_e_id, days, loc_ids, start_time, end_time)
    outer = []
    inner = []
    loc_ids.each do |loc_id|
      days.each do |day|
        seed_start_time = start_time
        seed_end_time = end_time
        while seed_end_time <= end_date
          seed_start_time = seed_start_time.next(day)
          seed_end_time = seed_end_time.next(day)
          inner.push "\"#{loc_id}\", \"#{cal_id}\", \"#{r_e_id}\", \"#{seed_start_time.to_s(:sql)}\", \"#{seed_end_time.to_s(:sql)}\", \"#{Time.now.to_s(:sql)}\", \"#{Time.now.to_s(:sql)}\""
          if inner.length > 450
            outer.push inner
            inner = []
          end
        end
      end
    end
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
