require 'spec_helper'
require 'capybara/rails'
require 'authlogic/test_case'


describe "timeslot creation process", :type => :feature do
  before :each do
    app_configs = build(:app_configs)
    department = build(:department)
    user = build(:admin)
    user.set_random_password
    user.departments << Department.first
    user.save
    sign_in("ad12")
    loc_group = build(:loc_group)
    # assume that it is Monday [specific date]
  end

  it "creates a timeslot" do
    visit '/time_slots/new'
    save_and_open_page
    within("#new_time_slot") do
      # fill_in DATE, :with => TOMORROW
      # fill_in time_slot_start_time_4i, :with => "10" #10am
      # ...more time
    end
    click_button 'Add'
    expect(page).to have_content 'Success'
  end

  xit "displays the timeslot properly on the time slots page" do
    visit '/time_slots'

    #didn't test this at all, but it's a good first guess.
    #this needs to be abstracted/future-proofed, of course
    expect(find('#location1_2014-09-25_timeslots')).to have_css('#timeslot346')
  end

  xit "displays the timeslot properly on the shifts page" do
    visit '/shifts'
  end
end

# An easy way to select a timeslot row
# @param
#   location_id id of the location we're looking for
#   day_of_week 1-7 to describe the day of the week
def time_slot_row(location_id, day_of_week)
  find("#location#{location_id} .timeslots")[day_of_week]
end