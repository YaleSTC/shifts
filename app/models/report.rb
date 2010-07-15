class Report < ActiveRecord::Base
  belongs_to :shift
  delegate :user, :to => :shift
  has_many :report_items, :dependent => :destroy

  validates_uniqueness_of :shift_id

  def get_notices
    @report_notices =  (self.shift.location.current_notices + self.shift.department.current_notices)
		a = @report_notices.select{|n| n.class.name == "Announcement"}.sort_by{|n| n.start}
		s = @report_notices.select{|n| n.class.name == "Sticky"}.sort_by{|n| n.start}
		return a + s
  end

  def get_links
    self.shift.location.links + self.shift.location.department.links
  end

  def data_objects
    self.shift.location.data_objects
  end

  def short_description
    "Shift in #{shift.location.name} (#{arrived.strftime("%I:%M%p")}-#{departed.strftime("%I:%M%p")})"
  end

  def duration
    (self.departed && self.arrived) ? ((self.departed - self.arrived) / 3600.0) : 0
  end
end

