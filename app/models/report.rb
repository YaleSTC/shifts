class Report < ActiveRecord::Base
  belongs_to :shift
  delegate :user, :to => :shift
  has_many :report_items, :dependent => :destroy

  validates_uniqueness_of :shift_id

  def get_notices
    (self.shift.location.current_notices + self.shift.user.current_notices).uniq
  end

  def get_links
    self.shift.location.links
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

