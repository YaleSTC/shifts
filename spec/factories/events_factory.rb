
module TimeHelper
  def local_date
    Date.new(2014,9,1)
  end

  def local_start_time
    local_date.to_time + 10.hours + 15.minutes
  end
  
  def local_end_time
    local_date.to_time + 16.hours + 45.minutes
  end

end

include TimeHelper

FactoryGirl.define do 
  factory :time_slot, class: TimeSlot do 
    location
    calendar
    start {local_start_time}
    self.end {local_end_time}
    # active entry is set automatically according to the status of calendar and location
  end

  # Pass in an array of location ids, or create a new location
  factory :repeating_time_slots, class: RepeatingEvent do 
    calendar
    ignore do 
      locations {[create(:location)]}
    end
    start_time {local_start_time}
    end_time {local_end_time}
    start_date {local_date}
    end_date {start_date+2.weeks}
    days_of_week "1,2,3,4,5,6,7"
    is_set_of_timeslots true
    after :build do |re, evaluator|
      re.loc_ids = evaluator.locations.map(&:id).join(',')
    end
    # create all dependent timeslots after id is assigned
    after :create do |re|
      re.make_future(true)
    end
  end
  
  factory :repeating_shifts, class: RepeatingEvent do 
    calendar
    ignore do 
      location {create(:location)}
      user {create(:user)}
    end
    start_time {local_start_time}
    end_time {local_end_time}
    start_date {local_date}
    end_date {start_date+2.weeks}
    days_of_week "1,2,3,4,5,6,7"
    is_set_of_timeslots false
    after :build do |re, evaluator|
      re.loc_ids = evaluator.location.id.to_s # Only one location is allowed
      re.user_id = evaluator.user.id
    end
    # create all dependent shifts after id is assigned
    after :create do |re|
      re.make_future(true)
    end
  end

  # Default calendar is created by DepartmentObserver
  factory :calendar do 
    department
    sequence(:name){|n| "#{ActiveSupport::Inflector.ordinalize(n)} Calendar"}
    start_date {local_date.beginning_of_year}
    end_date  {start_date.end_of_year}
    public false
    active false
    default false # Only built-in calendar is default
  end

  factory :shift do 
    department
    calendar
    user
    location
    scheduled true
    power_signed_up true # Otherwise shift is invalid without time_slot
    start {local_start_time}
    self.end {local_end_time}
  end

  factory :sub_request, class: SubRequest do
    shift
    reason "Out of town"
    after :build do |sub|
      sub.start = sub.shift.start
      sub.end = sub.shift.end
      sub.mandatory_start = sub.start
      sub.mandatory_end = sub.end
    end
  end 
end

