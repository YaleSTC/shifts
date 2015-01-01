require 'rails_helper'

describe "TimeSlot" , :time_slot do
  before :each do
    full_setup
    sign_in(@admin.login)
  end

  context "For one-time timeslot" do 
    it "can create time_slot" do
      expect do
        create_timeslot(Date.parse(@a_local_time.to_s))
        expect_flash_notice "Successfully created timeslot(s)"
      end.to change{TimeSlot.count}.by(1)
    end

    context "when timeslot is created", :shift do
      before :each do
        @slot = create(:time_slot, location: @location, calendar: @department.calendars.default)
      end

      def expect_time_slot_to_display_properly(slot, row)
        w, l = calculate_position(slot, @department.department_config)
        expect(row["style"]).to match(/width:\s*#{w.to_i}.*%\s*/)
        expect(row["style"]).to match(/left:\s*#{l.to_i}.*%\s*/)
      end

      it "displays the timeslot properly on the time slots page" do
        visit '/time_slots'
        expect_time_slot_to_display_properly(@slot, time_slot_row(@slot.location.id).find('li.timeslot'))
      end

      # Note that the part of time_slot in the past is not open
      it "displays the timeslot properly on the shifts schedule page" do 
        visit shifts_path
        expect_time_slot_to_display_properly(@slot, shift_schedule_row(@slot.location.id).find('li.bar_open'))
      end

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

      # Using selenium to handle alert
      it "can destroy timeslot", driver: :selenium do 
        visit time_slot_path(@slot)
        click_on "Destroy"
        # If using selenium driver
        page.driver.browser.switch_to.alert.accept
        expect_flash_notice "Successfully destroyed timeslot"
        expect{TimeSlot.find(@slot.id)}.to raise_error(ActiveRecord::RecordNotFound)
      end

    end
  end

  context "For repeating time_slots" do 
  end
end
