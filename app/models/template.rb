class Template < ActiveRecord::Base
	has_many :locations
	has_many :time_slots
	has_many :requested_shifts
	has_many :shift_preferences
	belongs_to :department
	has_and_belongs_to_many :roles
	
	validate :max_total_hours_greater_than_min
	validate :max_continuous_hours_greater_than_min
	validate :max_number_of_shifts_greater_than_min
	validates_presence_of :roles
	validates_presence_of :locations
	
	protected
	
	def max_total_hours_greater_than_min
	  errors.add(:max_total_hours, "max total hours must be greater min total hours") if (self.max_total_hours < self.min_total_hours)
  end
  
  def max_continuous_hours_greater_than_min
    errors.add(:max_continuous_hours, "max continuous hours must be greater min continuous hours") if (self.max_continuous_hours < self.min_continuous_hours)
  end
  
  def max_number_of_shifts_greater_than_min
    errors.add(:max_number_of_shifts, "max number of shifts must be greater min number of shifts") if (self.max_number_of_shifts < self.min_number_of_shifts)
  end
  
end
