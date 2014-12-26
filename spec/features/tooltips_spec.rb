require 'spec_helper'
require 'feature_helper'


describe "tooltip", js: true do
  before :each do
    app_setup
    @user = create(:admin)
    sign_in(@user.login)
  end

  context "tooltip with TimeSlots" do

    it "appears on timeslots page when you click an empty slot" do
      visit '/time_slots'
      first('.click_to_add_new_timeslot').click
      expect(page).to have_content "Add New Time Slot"
    end

    it "appears on timeslots page when you click on a timeslot" do
      create_timeslot
      visit '/time_slots'
      # find created timeslot
      time_slot_row(TimeSlot.last.location.id).first('.click_to_edit_timeslot').click
      expect(page).to have_content 'Destroy this time slot'
    end
  end
end
