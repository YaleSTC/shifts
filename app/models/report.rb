class Report < ActiveRecord::Base
  belongs_to :shift
  delegate :user, to: :shift
  has_many :report_items, dependent: :destroy

  validates_uniqueness_of :shift_id

  def get_notices
    a = self.shift.location.stickies.active + self.shift.location.announcements.active
    g = Notice.active.global.not_link
    # Custom search that sorts first by class then by start
    return (a + g).uniq.sort do |a, b|
      if a.class != b.class
        a.class.name <=> b.class.name
      else
        a.start <=> b.start
      end
    end
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
