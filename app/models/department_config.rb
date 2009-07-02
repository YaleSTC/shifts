class DepartmentConfig < ActiveRecord::Base
  belongs_to :department

  validates_presence_of :department_id
  validates_numericality_of :schedule_start, :schedule_end

  def self.default
    #Add payform config defaults?
    new(:time_increment => 60,
        :schedule_start => 540,
        :schedule_end => 17*60,
        :grace_period => 0,
        :edit_report => false)
  end

  def time_blocks
    (start..self.end).step(time_increment)
  end

  def calibrate_time
    if self
      self.end += 24*60 if self.end <= self.start
      self.save
    end
  end

end

