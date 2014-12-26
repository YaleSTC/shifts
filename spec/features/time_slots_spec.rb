require 'spec_helper'
require 'feature_helper'


describe "timeslot"  do
  before :each do
    app_setup
    @user = create(:admin)
    sign_in(@user.login)
  end

  it "can view the timeslot creation page" do
    visit '/time_slots/new'
    expect(page).to have_content 'New Time Slot'
  end

  context "when timeslot is created" do
    before :each do
      create_timeslot
    end

    it "displays success banner" do
       expect(page).to have_content 'Successfully created timeslot(s)'
    end

    it "displays the timeslot at all" do
      visit '/time_slots'
      expect(page).to have_css('div.time-slot')
    end

    it "displays the timeslot properly on the time slots page" do
      visit '/time_slots'
      expect(time_slot_row(TimeSlot.last.location.id)).to have_css('.time-slot') 
    end

    it "displays the timeslot properly on the shifts page" do
      visit '/shifts'
      expect(shift_schedule_row(TimeSlot.last.location.id)).to have_css('li.bar_open')
    end
  end
end
