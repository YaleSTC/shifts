class DepartmentConfig < ActiveRecord::Base
  belongs_to :department

  validates_presence_of :department_id
  validates_uniqueness_of :department_id
  validates_numericality_of :schedule_start, :schedule_end

  def calibrate_time
    if self
      self.schedule_end += 24*60 if self.schedule_end <= self.schedule_start
      self.save
    end
  end

end

