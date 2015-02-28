require 'rails_helper'

describe "TimeSlot" , :time_slot do
  before :each do
    full_setup
    sign_in(@admin.login)
  end

  context "For one-time timeslot" do 
    it "can create time_slot" do
      expect do
        create_timeslot(Date.today)
        expect_flash_notice "Successfully created timeslot(s)"
      end.to change{TimeSlot.count}.by(1)
    end

    context "when timeslot is created", :shift do
      before :each do
        @slot = create(:time_slot, location: @location, calendar: @calendar)
      end

      it "displays the timeslot properly on the time slots page" do
        visit '/time_slots'
        expect_time_slot_to_display_properly(@slot, time_slot_row(@slot.location.id, Date.today).find('li.timeslot'))
      end

      # Note that the part of time_slot in the past is not open
      it "displays the timeslot properly on the shifts schedule page" do 
        visit shifts_path
        expect_time_slot_to_display_properly(@slot, shift_schedule_row(@slot.location.id, Date.today).find('li.bar_open'))
      end

      # Note that when new loc_groups are created, the roles are NOT updated 
      # with the newly-generated permissions, therefore this new timeslot would
      # not be displayed on the timeslots page
      it "can update timeslot" do 
        c = create(:calendar); loc = create(:location)
        visit edit_time_slot_path(@slot)
        select c.name, from: "Calendar"
        fill_in_date("time_slot_start_date", @slot.start+2.day)
        select loc.name, from: "Location"
        click_on "Save Changes"
        expect_flash_notice "Successfully updated timeslot"
        expect{@slot.reload}.to change(@slot, :start)
        expect(@slot.calendar).to eq(c)
        expect(@slot.location).to eq(loc)
      end

      # Alternatively, one can use selenium to handle alert
      it "can destroy timeslot" do 
        visit time_slot_path(@slot)
        click_on "Destroy"
        # If using selenium driver
        # page.driver.browser.switch_to.alert.accept
        expect_flash_notice "Successfully destroyed timeslot"
        expect{TimeSlot.find(@slot.id)}.to raise_error(ActiveRecord::RecordNotFound)
      end

    end
  end

  context "For repeating time_slots" do 
    # Need JavaScript for the deletion submenu to work
    context "Different types of deletion", js: true do
      before :each do 
        @re = create(:repeating_time_slots, location_ids: [@location.id], calendar: @calendar)
        # getting the second timeslot in the series
        @slot = @re.time_slots.order(:start).second
        @count = TimeSlot.count
        visit edit_time_slot_path(@slot)
        click_on "Destroy this time slot"
      end
      it "can delete one single instance of timeslot" do 
        click_on "Just this time slot"
        expect_flash_notice "Successfully destroyed timeslot"
        expect{TimeSlot.find(@slot.id)}.to raise_error(ActiveRecord::RecordNotFound)
        expect(TimeSlot.count).to eq(@count-1)
      end 
      it "can delete future timeslots" do 
        click_on "This and all future time slots"
        visit time_slots_path
        # expect the first time_slot is still there
        expect(time_slot_row(@slot.location.id, Date.today)).to have_selector('li.timeslot')
        expect(TimeSlot.count).to eq(1)
      end
      it "can delete all timeslots in the series" do 
        click_on "All events in this series"
        visit time_slots_path
        expect(page).not_to have_selector('li.timeslot')
        expect(TimeSlot.count).to eq(0)
      end
    end
  end
end
