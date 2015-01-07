require 'rails_helper'

describe "Tooltip", js: true do 
	before :each do
    	full_setup
        @location2 = create(:location, loc_group: @loc_group)
  	end

	context "Tooltip on TimeSlot page", :time_slot do 
		before(:each) {sign_in(@admin.login)}

        context "New TimeSlot tooltip" do 
            def show_new_tooltip
                visit time_slots_path
                time_slot_row(@location2.id, @a_local_time+1.day).find('.click_to_add_new_timeslot').click
            end

            it 'can view the timeslot creation page on tooltip' do
                show_new_tooltip
                expect(page).to have_content "Add New Time Slot"
                expect(page).to have_select("Location", selected: @location2.name)
            end
            it 'can create one-time timeslot on tooltip' do 
                show_new_tooltip
                within("#new_time_slot") do
                    fill_in_date("time_slot_start_date", @a_local_time+1.day)
                    select "10 AM", :from => "time_slot_start_time_4i"
                    select "5 PM", :from => "time_slot_end_time_4i"
                end
                click_on "Create New"
                expect(time_slot_row(@location2.id, @a_local_time+1.day)).to have_selector('li.timeslot')
                expect(TimeSlot.count).to eq(1)
            end
            it 'can close tooltip' do 
                show_new_tooltip
                click_on "[esc]"
                expect(page).not_to have_selector('#tooltip')
            end
        end

    	it "can edit existing timeslot from tooltip" do
    		@slot = create(:time_slot, location: @location, calendar: @calendar)
        	visit '/time_slots'
        	# find created timeslot
        	time_slot_row(@slot.location.id, @a_local_time).first('.click_to_edit_timeslot').click
        	expect(page).to have_content 'Edit Timeslot'
            select "11 AM", from: "time_slot_start_time_4i"
            select "00", from: "time_slot_start_time_5i"
            click_on "Save Changes"
            expect(page).not_to have_selector("#tooltip") #Wait till tooltip closes
            expect{@slot.reload}.to change(@slot, :start)
            expect_time_slot_to_display_properly(@slot, time_slot_row(@slot.location.id, @a_local_time).first('li.timeslot'))
      	end
	end
end
