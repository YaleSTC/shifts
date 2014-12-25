def app_setup
  @app_config = create(:app_config)
  @department = create(:department)
  @loc_group = build(:loc_group, department: @department)
  @location = create(:location, loc_group: @loc_group)
  @a_local_time = Time.local(2014, 9, 1, 10, 5, 0)
  Timecop.freeze(@a_local_time)
end

def create_timeslot
  visit '/time_slots/new'
  #save_and_open_page
  within("#new_time_slot") do
    fill_in_date("time_slot_start_date", @a_local_time)
    select "10 AM", :from => "time_slot_start_time_4i"
    select "11 AM", :from => "time_slot_end_time_4i"
  end
  click_button 'Create New'
end

def fill_in_date(prefix, target_datetime)
  select target_datetime.year.to_s, :from => "#{prefix}_1i" 
  select Date::MONTHNAMES[target_datetime.month], :from => "#{prefix}_2i"
  select target_datetime.day.to_s, :from => "#{prefix}_3i"
end

# An easy way to select a timeslot row
# @param
#   location_id id of the location we're looking for
#   day_of_week 1-7 to describe the day of the week
def time_slot_row(location_id)
  find("#location#{location_id}_2014-09-01_timeslots")
end
