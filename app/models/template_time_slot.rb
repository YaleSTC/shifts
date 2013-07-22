class TemplateTimeSlot < ActiveRecord::Base
	belongs_to :template
	belongs_to :location

	validates_presence_of :start_time, :end_time, :day, :location_id, :template_id
	validate :start_less_than_end
	validate :no_concurrent_timeslots

	def start_less_than_end
    errors.add_to_base("Start time must be earlier than end time.") if (self.end_time <= start_time)
  end

  def no_concurrent_timeslots
    dont_conflict_with_self = (self.new_record? ? "" : "AND id != #{self.id}")
		c = TemplateTimeSlot.count(:all, :conditions => ["template_id  = #{self.template_id  } AND day  = #{self.day  } AND start_time  < #{self.end_time  } AND end_time  > #{self.start_time  } AND location_id  = #{self.location  } #{dont_conflict_with_self}"])
   # else
     # c = TimeSlot.count(:all, :conditions => ["#{:start } < #{self.end  } AND #{:end } > #{self.start  } AND #{:location_id } = #{self.location  } AND #{:calendar_id } = #{self.calendar  } #{dont_conflict_with_self}"])
    #end
		errors.add_to_base("There is a conflicting timeslot at the #{self.location.short_name}.") unless c.zero?
  end
end
