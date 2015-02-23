require 'rails_helper'

describe "Calendar Feeds" do 
	before :each do 
		full_setup
		@shift1 = create(:shift, department: @department, calendar: @calendar, user: @user, location: @location, start: Time.now+1.hour, end: Time.now+2.hour )
		@sub1 = create(:sub_request, shift: @shift1)
		@shift2 = create(:shift, department: @department, calendar: @calendar, user: @admin, location: @location, start: Time.now+3.hour, end: Time.now+4.hour )
		@sub2 = create(:sub_request, shift: @shift2)
		@shift3 = create(:shift, department: @department, calendar: @calendar, user: @user, location: @location, start: Time.now+5.hour, end: Time.now+6.hour )
		sign_in(@user.login)
	end

	it "should have correct shifts feeds", js:true do 
		visit calendar_feeds_path
		shifts_feed_link = within("div.feed_shifts") {find_link(@user.name)["href"].gsub(/^webcal/, "http")}
		open(shifts_feed_link) do |f|
			cal = Icalendar.parse(f).first
			events = cal.events
			expect(events.count).to eq(2)
			expect(events.first.summary).to include("sub requested!")
			expect(events.last.dtstart).to eq(@shift3.start.utc.to_s(:us_icaldate_utc))
		end
	end

	it "should have correct sub_request feeds", js: true do 
		visit calendar_feeds_path
		subss_feed_link = within("div.feed_subs") {find_link(@user.name)["href"].gsub(/^webcal/, "http")}
		open(subs_feed_link) do |f|
			cal = Icalendar.parse(f).first
			events = cal.events
			expect(events.count).to eq(1)
			expect(events.first.summary).to include(@admin.name)
		end
	end

	it "should reset calendar hash" do 
		visit calendar_feeds_path
		expect{click_on "Reset Feeds"}.to change{within("div.feed_shifts") {find_link(@user.name)["href"]}}
	end
end
