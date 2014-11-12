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

  xit "displays the timeslot properly on the time slots page" do
    create_timeslot
    visit '/time_slots'    
    # expect(SPECIFIC ROW).to have_css('.time-slot')
  end

  xit "displays the timeslot properly on the shifts page" do
    visit '/shifts'
  end
end
