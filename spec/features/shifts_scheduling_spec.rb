require 'rails_helper'

# Refer to the 'How to Schedule Shifts' google drive doc to learn
# about the shifts scheduling process in more detail. 

describe "Shifts scheduling", :shifts_scheduling, :time_slot, :shift do
  start_date = Date.new(2014, 9, 7) # aka 'go live' date
  end_date = Date.new(2015, 9, 7)

  before :each do
    full_setup
    @user2 = create(:user, nick_name: nil)
    sign_in(@admin.login)
  end

  it "can schedule shifts", driver: :selenium do

    ## Part 1. Prepare request calendar

    # Create a request calendar
    calendar_name = "Fall 2014 - ST Shift Requests"
    create_calendar(calendar_name, start_date, end_date) # go-live date
    expect_flash_notice "Successfully created calendar."
    calendar = Calendar.last
    
    # Advance in request calendar to week after start date
    click_link(calendar_name)
    next_week = start_date + 7.days
    visit calendar_path_on_date(calendar, next_week)

    # Create time slots for the week
    time_slot_row(@location.id, next_week).click    
    fill_repeating_time_slot_form(next_week, next_week+6.days, [@location], calendar_name)
    expect_flash_notice "Successfully created repeating event"

    ## Part 2. Get requests from workers
    [@user, @user2].each do |user|
      sign_in(user.login)
      visit calendar_path_on_date(calendar, next_week)
      (next_week..next_week+6.days).each do |date|
        shift_schedule_row(@location.id, date).first('.click_to_add_new_shift').click
        click_on "Create New"
        expect_shift_on_schedule(@location.id, date, user.name)
      end
    end
    # Check stats (should implement this in the view)
    sign_in(@admin.login)
    visit stats_path
    view_stats(calendar, next_week, next_week+6.days)
    expect(page).to have_content("7.0", count: 2)

    ## Part 3. Create Schedule Preview
    # Duplicating calendars
    calendar2 = copy_calendar(calendar, "Fall 2014 - ST Shift Request Copy")
    working_calendar = copy_calendar(calendar, "Fall 2014 - ST Shift Request Working Copy")

    # Make request calendar non-public
    visit edit_calendar_path(calendar)
    uncheck "Public"
    click_on "Submit"
    sign_in(@user2.login)
    visit calendar_path_on_date(calendar, next_week)
    expect_flash_notice "Only an administrator may view a private calendar."

    # Work on the working copy
    sign_in(@admin.login)
    visit calendar_path_on_date(working_calendar, next_week)
    ids = page.all("li[class^='click_to_edit_shift']").map{|li| li["id"].match(/shift(\d+)/)[1]}
    ids.each do |id|
      page.first("li#shift#{id}").click
      shift = Shift.find(id.to_i)
      select "30", from: "shift_start_time_5i" if shift.user == @user
      select "30", from: "shift_end_time_5i" if shift.user == @user2
      select working_calendar.name, from: "Calendar"
      if (1..5).include?(shift.start.wday)
        click_on "Save Changes" 
      else
        click_on "Destroy this shift"
      end
      expect(page).not_to have_content("Edit Shift")
    end
    
    # Copying working calendar as preview calendar
    preview_calendar = copy_calendar(working_calendar, "Fall 2014 - ST Shift Preview")
    # removing all time slots
    visit calendar_path_on_date(preview_calendar, next_week)
    page.first("li.click_to_edit_timeslot").click
    click_on "Destroy this time slot"
    click_on "All events in this series"
    visit edit_calendar_path(preview_calendar)
    check "Public"
    click_on "Submit"

    ## Part 4. 2nd Round changes
    # View preview as worker
    sign_in(@user.login)
    visit calendar_path_on_date(preview_calendar, next_week)
    expect(page).not_to have_selector("li[id^='timeslot']")

    ## Part 5. GO LIVE
    sign_in(@admin.login)
    schedule_calendar = copy_calendar(preview_calendar, "Fall 2014 - ST Shift Schedule")
    visit calendar_path(schedule_calendar)
    click_on "Convert Shifts to Weekly Events"
    page.driver.browser.switch_to.alert.accept
    expect_flash_notice "Schedule applied successfully."
    click_on "Activate"
    expect_flash_notice "The calendar was successfully activated"
    
    # Checking
    visit shifts_path + "?date="+format_date(start_date)
    expect(page).to have_content(@user.name)
    expect(page).to have_content(@user2.name)
    view_stats(nil, start_date, end_date)
    expect(page).to have_content("130.5")
    expect(page).to have_content("391.5")
  end
end
