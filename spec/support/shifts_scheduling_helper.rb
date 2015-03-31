module ShiftsSchedulingHelper

  def calendar_row(c)
    page.first("table tr", text: c.name)
  end


  # Capybara brower helpers, modifies browser state
  def create_calendar(name, start_date, end_date)
      visit '/calendars/new'
      within("#new_calendar") do
        fill_in "Name", with: name
        fill_in_date("calendar_start_date", start_date)
        fill_in_date("calendar_end_date", end_date)
        uncheck "Active"
        check 'Public'
      end
      click_button 'Submit'
  end

  def fill_repeating_time_slot_form(start_date, end_date, locs, calendar_name)
    check "Repeating event?"
    fill_in_date("repeating_event_start_date", start_date)
    fill_in_date("repeating_event_end_date", end_date)
    select "10 AM", from: "repeating_event_start_time_4i"
    select "05 PM", from: "repeating_event_end_time_4i"
    locs.each do |loc|
      check loc.short_name
    end
    select calendar_name, from: "Calendar"
    Date::DAYNAMES.each do |dayname|
      check dayname
    end
    uncheck "Wipe conflicts?"
    click_button "Create New Repeating Event"
  end
end
