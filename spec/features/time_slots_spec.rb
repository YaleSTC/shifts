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


    it 'can view the timeslot creation page on tooltip', js: true do
        visit '/time_slots'
        first('.click_to_add_new_timeslot').click
        expect(page).to have_content "Add New Time Slot"
    end

    context "when timeslot is created" do
      before :each do
        @slot = create(:time_slot, location: @location, calendar: @department.calendars.default)
      end

      it "displays the timeslot properly on the time slots page" do
        visit '/time_slots'
        w, l = calculate_position(@slot, @department.department_config)
        within time_slot_row(@slot.location.id) do 
          css=find('li.timeslot')["style"]
          expect(css).to match(/width:\s*#{w.to_i}.*%\s*;/)
          expect(css).to match(/left:\s*#{l.to_i}.*%\s*;/)
        end
      end

      xit "can update one-time timeslot" do 
        c = create(:calendar); loc = create(:location)
        visit edit_time_slot_path(@slot)
        save_and_open_page
      end

      it "displays the edit form on tooltip when you click on a timeslot", js: true do
        visit '/time_slots'
        # find created timeslot
        time_slot_row(@slot.location.id).first('.click_to_edit_timeslot').click
        expect(page).to have_content 'Edit Timeslot'
      end

      context "when navigate to shifts page", :shift do
        before :each do
          visit "/shifts"
        end
        it "displays the timeslot properly on the shifts page" do
          expect(shift_schedule_row(@slot.location.id)).to have_css('li.bar_open')
        end
      end
    end
  end
end
