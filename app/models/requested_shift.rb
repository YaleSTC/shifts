class RequestedShift < ActiveRecord::Base
	validates_presence_of :locations, :acceptable_start, :acceptable_end
	validate :proper_times
	validate :user_shift_preferences

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

	protected
	def user_shift_preferences
		shift_preference = self.user.shift_preferences.select{|sp| sp.template_id == self.template_id}.first
		errors.add_to_base("Your preferred shift length is longer than the maximum continuous hours you
												specified in your shift preferences") if (self.preferred_end - self.preferred_start)/60/60 > shift_preference.max_continuous_hours
		errors.add_to_base("Your preferred shift length is shorter than the minimum continuous hours you
												specified in your shift preferences") if (self.preferred_end - self.preferred_start)/60/60 < shift_preference.min_continuous_hours
		errors.add_to_base("Your preferred shift length is longer than the maximum shift hours per day you
												specified in your shift preferences") if (self.preferred_end - self.preferred_start)/60/60 > shift_preference.max_hours_per_day
	end

	def user_does_not_have_concurrent_request
		@week_template.requested_shifts
	end
	def proper_times
		errors.add_to_base("Acceptable start time cannot be after the acceptable end time") if self.acceptable_start > self.acceptable_end
		errors.add_to_base("Preferred start time cannot be after the preferred end time") if self.preferred_start > self.preferred_end
	end


end
