require 'rails_helper'

describe "TimeSlot" , :time_slot do
  before :each do
    full_setup
    sign_in(@admin.login)
  end

  it "can view the timeslot creation page" do
    visit '/time_slots/new'
    expect(page).to have_content 'New Time Slot'
  end

  it 'can view the timeslot creation page on tooltip', js: true do
      visit '/time_slots'
      first('.click_to_add_new_timeslot').click
      expect(page).to have_content "Add New Time Slot"
  end

  context "when timeslot is created" do
    before :each do
      create_timeslot(@a_local_time)
    end

    it "displays success banner" do
       expect_flash_notice 'Successfully created timeslot(s)'
    end

    it "displays the timeslot at all" do
      visit '/time_slots'
      expect(page).to have_css('div.time-slot')
    end

    it "displays the timeslot properly on the time slots page" do
      visit '/time_slots'
      expect(time_slot_row(TimeSlot.last.location.id)).to have_css('.time-slot') 
    end

    it "displays the edit form on tooltip when you click on a timeslot", js: true do
      visit '/time_slots'
      # find created timeslot
      time_slot_row(TimeSlot.last.location.id).first('.click_to_edit_timeslot').click
      expect(page).to have_content 'Edit Timeslot'
    end

    context "when navigate to shifts page", :shift do
      before :each do
        visit "/shifts"
      end
      it "displays the timeslot properly on the shifts page" do
        expect(shift_schedule_row(TimeSlot.last.location.id)).to have_css('li.bar_open')
      end
    end


  end
end
