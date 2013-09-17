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
		c = TemplateTimeSlot.count(:all, :conditions => ["#{:template_id.to_sql_column} = #{self.template_id.to_sql} AND #{:day.to_sql_column} = #{self.day.to_sql} AND #{:start_time.to_sql_column} < #{self.end_time.to_sql} AND #{:end_time.to_sql_column} > #{self.start_time.to_sql} AND #{:location_id.to_sql_column} = #{self.location.to_sql} #{dont_conflict_with_self}"])
   # else
     # c = TimeSlot.count(:all, :conditions => ["#{:start.to_sql_column} < #{self.end.to_sql} AND #{:end.to_sql_column} > #{self.start.to_sql} AND #{:location_id.to_sql_column} = #{self.location.to_sql} AND #{:calendar_id.to_sql_column} = #{self.calendar.to_sql} #{dont_conflict_with_self}"])
    #end
		errors.add_to_base("There is a conflicting timeslot at the #{self.location.short_name}.") unless c.zero?
  end
end
