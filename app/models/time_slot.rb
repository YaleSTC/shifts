class TimeSlot < ActiveRecord::Base
  belongs_to :location
  has_many :shifts, :through => :location
  
  validates_presence_of :start, :end, :location_id

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

  private


end
