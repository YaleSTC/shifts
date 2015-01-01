
module TimeHelper
	def self.local_start_time
		Time.zone.local(2014,9,1,10,15)
	end
	
	def self.local_end_time
		Time.zone.local(2014,9,1,16,45)
	end
end

FactoryGirl.define do 
	factory :time_slot, class: TimeSlot do 
		location
		calendar
		start {TimeHelper.local_start_time}
		self.end {TimeHelper.local_end_time}
		# active entry is set automatically according to the status of calendar and location
	end

	# Pass in an array of location ids, or create a new location
	factory :repeating_time_slots, class: RepeatingEvent do 
		calendar
		ignore do 
			location_ids {[create(:location).id]}
		end
		start_time {TimeHelper.local_start_time}
		end_time {TimeHelper.local_end_time}
		start_date {Date.parse(start_time.to_s)}
		end_date {start_date+2.weeks}
		days_of_week "1,2,3,4,5,6,7"
		is_set_of_timeslots true
		after :build do |re, evaluator|
			re.loc_ids = evaluator.location_ids.join(',')
		end
		# create all dependent timeslots after id is assigned
		after :create do |re|
			re.make_future(true)
		end
	end

	# Default calendar is created by DepartmentObserver
  	factory :calendar do 
    	department
    	sequence(:name){|n| "#{ActiveSupport::Inflector.ordinalize(n)} Calendar"}
    	start_date {Date.parse(TimeHelper.local_start_time.beginning_of_year.to_s)}
    	end_date  {start_date.end_of_year}
    	public false
    	active false
    	default false # Only built-in calendar is default
  	end
end

