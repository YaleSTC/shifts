class TemplateTimeSlot < ActiveRecord::Base
	belongs_to :template
	belongs_to :location

	validates_presence_of :start_time, :end_time, :day, :location_id, :template_id
	validate :start_less_than_end
	validate :no_concurrent_timeslots

	def start_less_than_end
    errors.add(:base, "Start time must be earlier than end time.") if (self.end_time <= start_time)
  end

  def no_concurrent_timeslots
    dont_conflict_with_self = (self.new_record? ? "" : "AND id != #{self.id}")
		c = TemplateTimeSlot.where("template_id = ? AND day = ? AND start_time < ? AND end_time  > ? AND location_id  = ? #{dont_conflict_with_self}", self.template_id, self.day, self.end_time, self.start_time, self.location).count
    # else
      # c = TimeSlot.count(:all, conditions: ["#{:start } < #{self.end  } AND #{:end } > #{self.start  } AND #{:location_id } = #{self.location  } AND #{:calendar_id } = #{self.calendar  } #{dont_conflict_with_self}"])
    #end
		errors.add(:base, "There is a conflicting timeslot at the #{self.location.short_name}.") unless c.zero?
  end
end
