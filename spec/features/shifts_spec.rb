require 'rails_helper'

describe "Shifts", :shift do 
	before(:each) do 
		full_setup
		sign_in(@admin.login)
	end
	context "For joining consecutive shifts" do 
		before(:each) do 
			@t1 = Time.now.beginning_of_hour+1.hour
		end
		it "should join two one-time shifts" do 
			@shift1 = create(:shift, calendar: @calendar, user: @user, location: @location, start: @t1, end: @t1+1.hour)
			@shift2 = create(:shift, calendar: @calendar, user: @user, location: @location, start: @t1+2.hour, end: @t1+3.hours)
			@shift3 = create(:shift, calendar: @calendar, user: @user, location: @location, start: @t1+1.hour, end: @t1+2.hours)
			visit shifts_path
			expect(all("li[id^='shift']").size).to eq(1)
			expect(Shift.first.duration).to eq(3)
		end

		# Massive import does not trigger callbacks, thus it won't merge shifts
		xit "shoud join shifts in repeating event" do 
			@shift1 = create(:shift, calendar: @calendar, user: @user, location: @location, start: @t1, end: @t1+1.hour)
			@shift2 = create(:shift, calendar: @calendar, user: @user, location: @location, start: @t1+2.hours, end: @t1+3.hours)
			pp @re = create(:repeating_shifts, calendar: @calendar, user: @user, location: @location, start_time: @t1+1.hour, end_time: @t1+2.hours)
			visit shifts_path
			expect(shift_schedule_row(@location.id, Date.today).all("li[id^='shift']").size).to eq(1)
			@shift = Shift.on_day(Date.today).first
			expect(@shift.duration).to eq(3)
		end
	end
end
