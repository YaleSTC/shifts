module ShiftsSchedulingHelper
	def create_calendar(name, start_date, end_date)
	    visit '/calendars/new'
	    within("#new_calendar") do
	    	fill_in "Name", with: name
	    	fill_in_date("calendar_start_date", start_date)
	    	fill_in_date("calendar_end_date", end_date)
	    	check 'Public'
	    end
	    click_button 'Submit'
	end
end