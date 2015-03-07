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
        # Open at the day after today
        time_slot_row(@location2.id, Date.tomorrow).find('.click_to_add_new_timeslot').click
      end

      it 'can view the timeslot creation page on tooltip with correct location' do
        show_new_tooltip
        expect(page).to have_content "Add New Time Slot"
        expect(page).to have_select("Location", selected: @location2.name)
      end
      it 'can create one-time timeslot on tooltip' do 
        show_new_tooltip
        within("#new_time_slot") do
          fill_in_date("time_slot_start_date", Date.today+1.day)
          select "10 AM", :from => "time_slot_start_time_4i"
          select "5 PM", :from => "time_slot_end_time_4i"
        end
        click_on "Create New"
        expect(time_slot_row(@location2.id, Date.tomorrow)).to have_selector('li.timeslot')
        expect(TimeSlot.count).to eq(1)
      end

      it 'can create repeating timeslots' do 
        show_new_tooltip
        check "Repeating event?"
        uncheck "Apply to entire calendar"
        fill_in_date("repeating_event_end_date", Date.today+2.weeks)
        select "10 AM", from: "repeating_event_start_time_4i"
        select "5 PM", from: "repeating_event_end_time_4i"
        check @location2.short_name
        select @calendar.name, from: "Calendar"
        uncheck "Saturday"
        check "Wipe conflicts?"
        click_on "Create New Repeating Event"
        expect_flash_notice "Successfully created repeating event"
        expect(TimeSlot.count).to be > 1
      end

      it 'can create repeating timeslots on entire calendar' do 
        c = create(:calendar, active: true)
        show_new_tooltip
        check "Repeating event?"
        check "Apply to entire calendar"
        select c.name, from: "Calendar"
        check "Wipe conflicts?"
        click_on "Create New Repeating Event"
        expect_flash_notice "Successfully created repeating event"
        expect(TimeSlot.count).to be >= (c.end_date-Time.now)/3600/24/7
      end


      it 'can close tooltip' do 
        show_new_tooltip
        click_on "[esc]"
        expect(page).not_to have_selector('#tooltip')
      end
    end

    context "Tooltip for existing timeslots" do 
      before(:each) {@slot = create(:time_slot, location: @location, calendar: @calendar)} 
      def show_edit_tooltip
        visit '/time_slots'
        # find created timeslot
        time_slot_row(@slot.location.id, Date.today).first('.click_to_edit_timeslot').click  
      end

      it "can edit existing timeslot from tooltip" do
        show_edit_tooltip
        expect(page).to have_content 'Edit Timeslot'
        select "11 AM", from: "time_slot_start_time_4i"
        select "00", from: "time_slot_start_time_5i"
        click_on "Save Changes"
        expect(page).not_to have_selector("#tooltip") #Wait till tooltip closes
        expect{@slot.reload}.to change(@slot, :start)
        expect_time_slot_to_display_properly(@slot, time_slot_row(@slot.location.id, Date.today).first('li.timeslot'))
      end
      it 'can destroy timeslot from tooltip' do 
        show_edit_tooltip
        click_on "Destroy this time slot"
        expect(page).not_to have_selector('#tooltip')
        expect(time_slot_row(@slot.location.id, Date.today)).not_to have_selector('li.timeslot')
        expect{TimeSlot.find(@slot.id)}.to raise_error(ActiveRecord::RecordNotFound)
      end
    end
	end

  context "Tooltip on Shifts Page", :shift do
    before(:each) do
      start_time = Date.tomorrow.to_time+@department.department_config.schedule_start.minutes
      end_time = Date.tomorrow.to_time+@department.department_config.schedule_end.minutes-1.hour
      create(:time_slot, location: @location2, calendar: @calendar, start: start_time, end: end_time)
    end

    context "New Shift Tooltip" do 
      def show_new_tooltip
        visit shifts_path
        shift_schedule_row(@location2.id, Date.tomorrow).first('li.click_to_add_new').click
      end
      
      it 'can view the shift creation page on tooltip with correct location' do 
        sign_in(@admin.login)
        show_new_tooltip
        expect(page).to have_content("New Shift")
        expect(page).to have_select("Location", @location2.name)
      end

      it 'ordinary user can create one-time shift' do 
        sign_in(@user.login)
        show_new_tooltip
        within('#new_shift') do 
          select "11 AM", from: "shift_start_time_4i"
          select "01 PM", from: "shift_end_time_4i"
        end
        click_on "Create New"
        expect(page.find("li[id*='shift']")).to have_content(@user.name)
        expect(Shift.count).to eq(1)
      end

      it 'admin can create one-time shift' do 
        sign_in(@admin.login)
        show_new_tooltip
        within('#new_shift') do 
          select "11 AM", from: "shift_start_time_4i"
          select "01 PM", from: "shift_end_time_4i"
          select @admin.name, from: "User"
        end
        click_on "Create New"
        expect(page.find("li[id*='shift']")).to have_content(@admin.name)
        expect(Shift.count).to eq(1)
      end

      it 'can create repeating shifts' do 
        sign_in(@admin.login)
        show_new_tooltip
        check "Repeating event?"
        uncheck "Apply to entire calendar"
        fill_in_date("repeating_event_end_date", Date.today+2.weeks)
        select "11 AM", from: "repeating_event_start_time_4i"
        select "01 PM", from: "repeating_event_end_time_4i"
        select @location2.name, from: "Location"
        select @user.name, from: "User"
        select @calendar.name, from: "Calendar"
        check "Friday"
        uncheck "Saturday"
        check "Wipe conflicts?"
        click_on "Create New Repeating Event"
        expect_flash_notice "Successfully created repeating event"
        expect(Shift.count).to be > 1
      end

      it 'can create repeating shifts on entire calendar' do 
        c = create(:calendar, active: true)
        sign_in(@admin.login)
        show_new_tooltip
        check "Repeating event?"
        check "Apply to entire calendar"
        select @user.name, from: "User"
        select c.name, from: "Calendar"
        check "Wipe conflicts?"
        click_on "Create New Repeating Event"
        expect_flash_notice "Successfully created repeating event"
        expect(@user.shifts.count).to be >= (c.end_date-Time.now)/3600/24/7
      end
      
      it 'can close tooltip' do 
        sign_in(@user.login)
        show_new_tooltip
        click_on "[esc]"
        expect(page).not_to have_selector('#tooltip')
      end
    end

    context "Tooltip for existing shifts" do 
      before(:each) {sign_in(@admin.login)}
      def show_shift_tooltip(shift)
        visit shifts_path
        shift_in_schedule(shift).click    
      end
      context "Edit Shift Tooltip" do 
        it 'can edit one-time shift' do 
          shift = create(:shift, calendar: @calendar, location: @location, user: @user)
          show_shift_tooltip(shift)
          select @location2.name, from: "Location"
          click_on "Save Changes"
          expect(page).not_to have_selector("#tooltip")
          expect{shift.reload}.to change(shift, :location)
          expect(shift_schedule_row(@location2.id, shift.start)).to have_selector("li#shift#{shift.id}")
        end
        it 'can edit repeating shifts' do 
          re = create(:repeating_shifts, calendar: @calendar, location: @location, user: @user)
          shift = re.shifts.on_day(Date.today).first
          show_shift_tooltip(shift)
          check "Edit repeating event"
          select @location2.name, from: "Location"
          select @admin.name, from: "User"
          uncheck "Saturday"
          click_on "Update Repeating Event"
          expect_flash_notice "Successfully edited repeating event"
          expect(Shift.where(location_id: @location.id)).to be_empty
          expect(Shift.where(location_id: @location2.id)).not_to be_empty
        end
      end

      it 'can view shift report tooltip'
      it 'can take sub request on tooltip'

      context "Destroy Shift Tooltip" do 
        before(:each) do
          @re = create(:repeating_shifts, calendar: @calendar, location: @location, user: @user)
          @shift1 = @re.shifts.order(:start).first
          @shift = @re.shifts.order(:start).second
          @count = @re.shifts.count
          visit shifts_path
          shift_schedule_row(@location.id, @shift.start).first("li#shift#{@shift.id}").click
          click_on "Destroy this shift"
        end
        it 'can delete one instance of repeating shifts' do 
          click_on "Just this shift"
          expect_flash_notice "Successfully destroyed shift"
          expect{Shift.find(@shift.id)}.to raise_error(ActiveRecord::RecordNotFound)
          expect(Shift.count).to eq(@count-1)
        end
        it 'can delete future repeating shifts' do 
          click_on "This and all future shifts"
          visit shifts_path
          expect(shift_schedule_row(@location.id, @shift1.start)).to have_selector("li#shift#{@shift1.id}")
          expect(Shift.count).to eq(1)
        end
        it 'can delete all repeating shifts in series' do 
          click_on "All events in this series"
          visit shifts_path
          expect(page).not_to have_selector("li[id^='shift']")
          expect(Shift.count).to eq(0)
        end
      end
    end
    
  end
end
