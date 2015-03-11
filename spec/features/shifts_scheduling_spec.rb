require 'rails_helper'

# Refer to the 'How to Schedule Shifts' google drive doc to learn
# about the shifts scheduling process in more detail. 

describe "Shifts scheduling", :shifts_scheduling, :time_slot do
	start_date = Date.new(2014, 9, 7) # aka 'go live' date
	end_date = Date.new(2015, 9, 7)

	before :each do
		full_setup
		sign_in(@admin.login)
	end

	it "can schedule shifts", driver: :selenium do

		## Part 1. Prepare request calendar

		# Create a request calendar
		calendar_name = "Fall 2014 - ST Shift Requests"
		create_calendar(calendar_name, start_date, end_date) # go-live date
		expect_flash_notice "Successfully created calendar."
		
		# Advance in request calendar to week after start date
		click_link(calendar_name)
		next_week = start_date + 7.days
		formatted_date = "#{next_week.year}-#{next_week.mon}-#{next_week.day}"
		calendar_path_with_date = current_path + "?date=" + formatted_date
		visit calendar_path_with_date

		# Create time slots for the week
		time_slot_row(@location.id, next_week).click		
		fill_repeating_time_slot_form(next_week, next_week+6.days, [@location], calendar_name)
		expect_flash_notice "Successfully created repeating event"

		## Part 2. Get requests from workers
		sign_in(@user.login)
		visit calendar_path_with_date
				
		save_and_open_page


	end
end
