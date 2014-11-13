require 'spec_helper'
require 'feature_helper'
require 'capybara/rails'


describe "tooltip", js: true, :type => :feature do
  before :each do
    app_setup
    @user = create(:admin)
    sign_in(@user.login)
  end

  it "appears on timeslots page when you click an empty slot" do
    visit '/time_slots'
    first('.click_to_add_new_timeslot').click
    save_and_open_page
    expect(page).to have_content "Add New Time Slot"
  end

  xit "appears on timeslots page when you click on a timeslot" do
    create_timeslot
    visit '/time_slots'
    # find created timeslot
    expect(page).to have_content 'New Shift'
  end
end
