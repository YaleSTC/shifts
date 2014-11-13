require 'spec_helper'
require 'feature_helper'
require 'capybara/rails'


describe "timeslot creation process", :type => :feature do
  before :each do
    app_setup
    @user = create(:admin)
    sign_in(@user.login)
  end

  it "can view the main page" do
    visit '/'
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

  it "displays the timeslot properly on the time slots page" do
    create_timeslot
    visit '/time_slots'
    expect(time_slot_row(4)).to have_css('.time-slot') # loc_id 4 is TTO
  end

  xit "displays the timeslot properly on the shifts page" do
    create_timeslot
    visit '/shifts'
    expect(time_slot_row()).to have_css('.time-slot')
  end
end