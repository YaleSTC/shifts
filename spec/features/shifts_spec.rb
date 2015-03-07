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
			@shift2 = create(:shift, calendar: @calendar, user: @user, location: @location, start: @t1+1.hour, end: @t1+2.hour)
			visit shifts_path
			expect(all("li[id^='shift']").size).to eq(1)
		end

		it "shoudl join shifts in repeating event"
	end
end
