require 'rails_helper'

describe "Tooltip" do 
	before :each do
    	full_setup
  	end
	context "Tooltip on TimeSlot page", :time_slot do 
		before(:each) {sign_in(@admin.login)}

		it 'can view the timeslot creation page on tooltip', js: true do
        	visit '/time_slots'
        	first('.click_to_add_new_timeslot').click
        	expect(page).to have_content "Add New Time Slot"
    	end
    	it "displays the edit form on tooltip when you click on a timeslot", js: true do
    		@slot = create(:time_slot, location: @location, calendar: @department.calendars.default)
        	visit '/time_slots'
        	# find created timeslot
        	time_slot_row(@slot.location.id).first('.click_to_edit_timeslot').click
        	expect(page).to have_content 'Edit Timeslot'
      	end
	end
end