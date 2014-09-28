require 'spec_helper'
require 'capybara/rails'


describe "timeslot creation process", :type => :feature do
  before :each do
    app_setup
    @user = create(:admin)
    sign_in(@user.login)
  end

  it "can view the main page" do
    visit '/'
    save_and_open_page
    expect(page).to have_content 'Your Shifts'
  end

  it "creates a timeslot" do
    create_timeslot
    expect(page).to have_content 'Success'
  end

  it "displays the timeslot at all" do
    create_timeslot
    visit '/time_slots'
    expect(page).to have_css('.time-slot')
  end

  xit "displays the timeslot properly on the time slots page" do
    create_timeslot
    visit '/time_slots'    
    # expect(SPECIFIC ROW).to have_css('.time-slot')
  end

  xit "displays the timeslot properly on the shifts page" do
    visit '/shifts'
  end
end


#
## Common Actions
#

def app_setup
  @app_config = create(:app_config)
  @department = create(:department)
  @loc_group = build(:loc_group, department: @department)
  @location = create(:location, loc_group: @loc_group)
end

def create_timeslot
  visit '/time_slots/new'
  within("#new_time_slot") do
    # fill_in DATE, :with => TOMORROW
    # fill_in time_slot_start_time_4i, :with => "10" #10am
    # ...more time
  end
  click_button 'Add'
end


# THIS DOESN'T WORK
# An easy way to select a timeslot row
# @param
#   location_id id of the location we're looking for
#   day_of_week 1-7 to describe the day of the week
# def time_slot_row(location_id, day_of_week)
#   find("#location#{location_id} .timeslots")[day_of_week]
# end