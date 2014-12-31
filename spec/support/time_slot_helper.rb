module TimeSlotHelper
  # Capybara browser helpers, modifies browser state
  def create_timeslot(date)
    visit '/time_slots/new'
    within("#new_time_slot") do
      fill_in_date("time_slot_start_date", date)
      select "10 AM", :from => "time_slot_start_time_4i"
      select "5 PM", :from => "time_slot_end_time_4i"
    end
    click_button 'Create New'
  end


  # Capybara page finder helpers, does not modify browser state
  # returns the location row in timeslot index page
  def time_slot_row(location_id)
    page.all("#location#{location_id}_#{@a_local_time.strftime("%Y-%m-%d")}_timeslots")[0]
  end

  # Other helpers
  def calculate_position(slot, config)
    entire = (config.schedule_end-config.schedule_start).minutes
    width_per = 100*(slot.end-slot.start).to_f / entire
    left_per = 100*(slot.start.seconds_since_midnight-config.schedule_start.minutes).to_f / entire
    return width_per, left_per
  end
end
