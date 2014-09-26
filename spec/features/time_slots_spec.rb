require 'spec_helper'
require 'capybara/rails'
require 'authlogic/test_case'


describe "timeslot creation process", :type => :feature do
  before :each do
    app_configs = create(:app_configs)
    department = create(:department)
    user = build(:admin)
    user.set_random_password
    user.departments << Department.first
    user.save
    sign_in(user.login)
    loc_group = create(:loc_group)
    location = create(:location)
    # assume that it is Monday [specific date]
  end

  it "creates a timeslot" do
    create_timeslot
    expect(page).to have_content 'Success'
  end

  it "displays the timeslot properly on the time slots page" do
    create_timeslot
    visit '/time_slots'
    save_and_open_page
    #didn't test this at all, but it's a good first guess.
    #this needs to be abstracted/future-proofed, of course
    expect(find('#location1_2014-09-25_timeslots')).to have_css('#timeslot346')
  end

  xit "displays the timeslot properly on the shifts page" do
    visit '/shifts'
  end
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

# An easy way to select a timeslot row
# @param
#   location_id id of the location we're looking for
#   day_of_week 1-7 to describe the day of the week
def time_slot_row(location_id, day_of_week)
  find("#location#{location_id} .timeslots")[day_of_week]
end