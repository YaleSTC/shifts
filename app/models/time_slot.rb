class TimeSlot < ActiveRecord::Base
  belongs_to :location
  belongs_to :calendar
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
