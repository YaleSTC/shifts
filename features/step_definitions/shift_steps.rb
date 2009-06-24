Given /^I am not logged into a shift$/ do
  @current_user.shifts.each do |n|
    n.report == nil
  end
end

Given /^I am logged into a shift$/ do
  @current_user.shifts.each do |n|
    n.report == nil?
  end
end

Given /^I have a time_slot in "([^\"]*)", from "([^\"]*)" to "([^\"]*)"$/ do |location, start_time, end_time|
  TimeSlot.create!(:location_id => Location.find_by_name(location).id,
                   :start       => Time.parse(start_time),
                   :end         => Time.parse(end_time))
end

Given /^"([^\"]*)" has a scheduled shift, in "([^\"]*)", from "([^\"]*)" to "([^\"]*)"$/ do |arg1, arg2, arg3, arg4, arg5|
  pending
end
Given /^"([^\"]*)" has a scheduled shift, in "([^\"]*)", from "([^\"]*)" to "([^\"]*)" and signed in at "([^\"]*)"$/ do |user, location, start_time, end_time, arrived|
  s = Shift.create!(:user_id     => User.find_by_name(user).id,
                :location_id => Location.find_by_name(location).id,
                :start       => Time.parse(start_time),
                :end         => Time.parse(end_time))

  that_report = Report.create!(:shift_id => s.id,
                 :arrived  => Time.parse(arrived))
end


Then /^that_report is not late$/ do
  that_report.is_late? == false
end

Then /^that_report is late$/ do
  that_report.is_late? == true
end

Then /^my shift report should have ([0-9]+) comment$/ do |count|
  @shift = @current_user.shifts[0]
  @shift.report.report_items.count.should == count.to_i
end

