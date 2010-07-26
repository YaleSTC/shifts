class ShiftPreference < ActiveRecord::Base
	belongs_to :user
	has_many :locations_shift_preferences
	has_many :locations, :through => :locations_shift_preferences
	belongs_to :template
	
	validate :max_total_hours_greater_than_min
	validate :max_continuous_hours_greater_than_min
	validate :max_number_of_shifts_greater_than_min
  # validate :feasibility_of_preferences
	
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
	
	def feasibility_of_preferences
	  errors.add(:)
  end
	
end
