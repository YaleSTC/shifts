class DepartmentConfig < ActiveRecord::Base
  belongs_to :department

  validates_presence_of :department_id
  validates_uniqueness_of :department_id
  validates_numericality_of :schedule_start, :schedule_end
  validate :increment_factor_of_60

  def calibrate_time
    #allow the schedule for a day to end at, say, 2:00am
    if self
      self.schedule_end += 24*60 if self.schedule_end <= self.schedule_start
      self.save
    end
  end


  # methods for use in the schedule view
  def blocks_per_hour
    60 / self.time_increment
  end

  def blocks_per_day
    ((self.schedule_end - self.schedule_start) / self.time_increment).to_i
  end

  def block_length
    self.time_increment * 60 #seconds
  end

protected

  def increment_factor_of_60
    errors.add(:time_increment, "must divide evenly into 60") unless 60 % self.time_increment == 0
  end

end

