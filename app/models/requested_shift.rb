class RequestedShift < ActiveRecord::Base
	validates_presence_of :acceptable_start, :acceptable_end
	validates_presence_of :locations, :on => :update
	validate :proper_times
	#validate :user_shift_preferences
	validate :user_does_not_have_concurrent_request
	validate :request_is_within_time_slot

	has_many :locations_requested_shifts
	has_many :locations, :through => :locations_requested_shifts
	belongs_to :user
	belongs_to :template

 	named_scope :assigned, lambda {|location| {:conditions => ["locations_requested_shifts.assigned = ? AND locations_requested_shifts.location_id = ?", true,  location.id], :joins => :locations_requested_shifts }}
 	named_scope :unassigned, lambda {|location| {:conditions => ["locations_requested_shifts.assigned = ? AND locations_requested_shifts.location_id = ?", false,  location.id], :joins => :locations_requested_shifts }}
	named_scope :on_day, lambda {|day| {:conditions => {:day => day}}}

	WEEK_DAY_SELECT = [
    ["Monday", 0],
    ["Tuesday", 1],
    ["Wednesday", 2],
    ["Thursday", 3],
    ["Friday", 4],
    ["Saturday", 5],
    ["Sunday", 6]
  ]

	def locations
		LocationsRequestedShift.find(:all, :conditions => ['requested_shift_id = ?', self.id]).collect{|lrs| Location.find(lrs.location_id)}
	end

  def self.day_in_words(day_int)
    WEEK_DAY_SELECT.select{|i| i[1] == day_int}[0][0]
  end

  def length
    self.acceptable_end - self.acceptable_start
  end

  def day_string
    RequestedShift.day_in_words(self.day)
  end

  def overlaps_with(shift)
    self.acceptable_start >= shift.acceptable_start and self.acceptable_start < shift.acceptable_end
  end

	def assign(location)
		@location_request = LocationsRequestedShift.find(:first, :conditions => {:requested_shift_id => self.id, :location_id => location.id})
		@location_request.assigned = true
		@location_request.save
	end

	#protected
	def user_shift_preferences
		shift_preference = self.user.shift_preferences.select{|sp| sp.template_id == self.template_id}.first
		errors.add_to_base("Your preferred shift length is longer than the maximum continuous hours you
												specified in your shift preferences") if (self.preferred_end - self.preferred_start)/60/60 > shift_preference.max_continuous_hours
		errors.add_to_base("Your preferred shift length is shorter than the minimum continuous hours you
												specified in your shift preferences") if (self.preferred_end - self.preferred_start)/60/60 < shift_preference.min_continuous_hours
		errors.add_to_base("Your preferred shift length is longer than the maximum shift hours per day you
												specified in your shift preferences") if (self.preferred_end - self.preferred_start)/60/60 > shift_preference.max_hours_per_day
	end
	
	def request_is_within_time_slot
		b = self.locations
		c = 0
		b.each do |location|		
			c += TemplateTimeSlot.count(:all, :conditions => ["#{:start_time.to_sql_column} <= #{self.acceptable_start.to_sql} AND #{:end_time.to_sql_column} >= #{self.acceptable_end.to_sql} AND #{:template_id.to_sql_column} = #{self.template_id.to_sql} AND #{:location_id.to_sql_column} = #{location.id.to_sql} AND #{:day.to_sql_column} = #{self.day.to_sql}"])
		end
		errors.add_to_base("You can only sign up for a shift during a time slot.") if c == 0
  end

  def user_does_not_have_concurrent_request
		#Find all other requests of the user that occupy the same time (same day + overlapping acceptable start/end time)
		c = RequestedShift.find(:all, :conditions => ["#{:user_id.to_sql_column} = #{self.user_id.to_sql} AND #{:day.to_sql_column} = #{self.day.to_sql} AND #{:acceptable_start.to_sql_column} <= #{self.acceptable_end.to_sql} AND #{:acceptable_end.to_sql_column} >= #{self.acceptable_start.to_sql} AND #{:template_id.to_sql_column} = #{self.template.to_sql}"])
		#Now see if any of the other requests have locations that are the same as this request's locations
		other_locations = []
		c.each do |request|
			other_locations << request.locations
		end
#		puts "other locations"
#		puts other_locations.to_yaml
#		puts "self locations"
		puts "locations for current request"
		puts self.locations.to_yaml
		self.locations.each do |location|	
			errors.add_to_base("Your request is overlapping with another one of your requests at #{location.short_name}") if other_locations.include?(location)
		end
  end

	def proper_times
		if self.preferred_start
			errors.add_to_base("Preferred start time must be after or the same as the acceptable start time") if self.preferred_start < self.acceptable_start
		end
		if self.preferred_end
			errors.add_to_base("Preferred end time must be before or the same as the acceptable end time") if self.preferred_end > self.acceptable_end
		end
		errors.add_to_base("Acceptable start time cannot be after the acceptable end time") if self.acceptable_start > self.acceptable_end
		if self.preferred_start && self.preferred_end
			errors.add_to_base("Preferred start time cannot be after the preferred end time") if self.preferred_start > self.preferred_end
		end
	end
end
