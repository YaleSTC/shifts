class RequestedShift < ActiveRecord::Base
	validates_presence_of :acceptable_start, :acceptable_end
	validates_presence_of :locations, on: :update
	validate :proper_times
	#validate :user_shift_preferences
	validate :user_does_not_have_concurrent_request
	validate :request_is_within_time_slot

  # has_many :locations_requested_shifts
  # has_many :locations, :through => :locations_requested_shifts
	belongs_to :user
	belongs_to :template

 	scope :assigned, where("requested_shifts.assigned_start < ?", Time.now.utc)
 	scope :unassigned, where("requested_shifts.assigned_start is null")
# 	scope :unassigned, lambda {|location| {:conditions => ["requested_shifts.assigned_start = ? AND locations_requested_shifts.location_id = ?", nil,  location.id], :joins => :locations_requested_shifts }}
	scope :on_day, ->(day){where(day: day)}
  # scope :at_location, lambda {|location| {:conditions => ["locations_requested_shifts.location_id = ?", location.id], :joins => :locations_requested_shifts }}

	WEEK_DAY_SELECT = [	["Monday", 0],
    									["Tuesday", 1],
    									["Wednesday", 2],
    									["Thursday", 3],
    									["Friday", 4],
    									["Saturday", 5],
    									["Sunday", 6] ]
	def assigned(location)
		LocationsRequestedShift.where('requested_shift_id = ?', self.id).collect{|lrs| Location.find(lrs.location_id)}
	end

	def locations
		LocationsRequestedShift.where('requested_shift_id = ?', self.id).collect{|lrs| Location.find(lrs.location_id)}
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
		@location_request = LocationsRequestedShift.where(requested_shift_id: self.id, location_id: location.id).first
		@location_request.assigned = true
		@location_request.save
	end

	#protected
	def user_shift_preferences
		shift_preference = self.user.shift_preferences.select{|sp| sp.template_id == self.template_id}.first
		errors.add(:base, "Your preferred shift length is longer than the maximum continuous hours you
												specified in your shift preferences") if (self.preferred_end - self.preferred_start)/60/60 > shift_preference.max_continuous_hours
		errors.add(:base, "Your preferred shift length is shorter than the minimum continuous hours you
												specified in your shift preferences") if (self.preferred_end - self.preferred_start)/60/60 < shift_preference.min_continuous_hours
		errors.add(:base, "Your preferred shift length is longer than the maximum shift hours per day you
												specified in your shift preferences") if (self.preferred_end - self.preferred_start)/60/60 > shift_preference.max_hours_per_day
	end

	def request_is_within_time_slot
		b = self.locations
		c = 0
		b.each do |location|
      values = self.acceptable_start, self.acceptable_end, self.template_id, location.id, self.day
      conditions = "start_time <= ? AND end_time >= ? AND template_id = ? AND location_id = ? AND day = ?}"
			c += TemplateTimeSlot.where(conditions, *values).count
		end
		errors.add(:base, "You can only sign up for a shift during a time slot.") if c == 0
  end

  def user_does_not_have_concurrent_request
#		Find all other requests of the user that occupy the same time (same day + overlapping acceptable start/end time)
    values = [self.user_id, self.day, self.acceptable_end, self.acceptable_start, self.template, self.id]
		c = RequestedShift.where("user_id = ? AND day = ? AND acceptable_start  <= ? AND acceptable_end >= ? AND template_id = ? AND id != ?", *values)
#		Now see if any of the other requests have locations that are the same as this request's locations
		other_locations = c.collect{|request| request.locations}.flatten
		self.locations.each do |location|
			errors.add(:base, "Your request is overlapping with another one of your requests at #{location.short_name}") if other_locations.include?(location)
		end
  end

	def proper_times
		if self.preferred_start
			errors.add(:base, "Preferred start time must be after or the same as the acceptable start time") if self.preferred_start < self.acceptable_start
		end
		if self.preferred_end
			errors.add(:base, "Preferred end time must be before or the same as the acceptable end time") if self.preferred_end > self.acceptable_end
		end
		errors.add(:base, "Acceptable start time cannot be after the acceptable end time") if self.acceptable_start > self.acceptable_end
		if self.preferred_start && self.preferred_end
			errors.add(:base, "Preferred start time cannot be after the preferred end time") if self.preferred_start > self.preferred_end
		end
	end
end
