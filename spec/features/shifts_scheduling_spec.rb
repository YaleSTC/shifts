require 'rails_helper'

# Refer to the 'How to Schedule Shifts' google drive doc to learn
# about the shifts scheduling process in more detail. 

describe "Shifts scheduling", :shifts_scheduling, js: true do
	start_date = Date.new(2014, 9, 7) # aka 'go live' date
	end_date = Date.new(2015, 9, 7)

	before :each do
		full_setup
		sign_in(@admin.login)
	end

	it "can schedule shifts" do

		## Part 1. Prepare request calendar

		# Create a request calendar
		calendar_name = "Fall 2014 - ST Shift Requests"
		create_calendar(calendar_name, start_date, end_date) # go-live date
		expect_flash_notice "Successfully created calendar."
		
		# Advance in request calendar to week after start date
		click_link(calendar_name)
		next_week = start_date + 7
		formatted_date = "#{next_week.year}-#{next_week.mon}-#{next_week.day}"
		visit current_path + "?date=" + formatted_date
		save_and_open_page
	end
end
