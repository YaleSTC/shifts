class Report < ActiveRecord::Base
  belongs_to :shift
  delegate :user, :to => :shift
  has_many :report_items, :dependent => :destroy

  validates_uniqueness_of :shift_id

  def get_notices
    @report_notices =  (self.shift.location.current_notices)
    # department.current_notices is not necessary because a department-wide notice is already posted in location. 
		a = @report_notices.select{|n| n.class.name == "Announcement"}.sort_by{|n| n.start}
		s = @report_notices.select{|n| n.class.name == "Sticky"}.sort_by{|n| n.start}
		return a + s
  end

  def get_links
     a = self.shift.location.links.active
     b = Link.global.active
     (a + b).sort_by(&:start).uniq
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
