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

Given /^there is a scheduled shift:$/ do |table|
  table.hashes.each do |row|
    TimeSlot.create!(:location_id => Location.find_by_name(row[:location]).id,
                     :start       => Time.parse(row[:start_time]),
                     :end         => Time.parse(row[:end_time]),
                     :calendar_id => Calendar.find(1))
    user = User.find(:first, :conditions => {:first_name => row[:user].split.first, :last_name => row[:user].split.last})
    @that_shift = Shift.create!(:user_id     => user.id,
                           :location_id => Location.find_by_name(row[:location]).id,
                           :start       => Time.parse(row[:start_time]),
                           :end         => Time.parse(row[:end_time]),
                           :department_id => user.departments.first,
                           :calendar_id => Calendar.find(1))
  end
end

Given /^"([^\"]*)" signs in at "([^\"]*)"$/ do |user, arrived|
  @that_report = Report.create!(:shift_id => @that_shift.id,
                                :arrived  => Time.parse(arrived))
end

When /^I comment in that_report "([^\"]*)"$/ do |content|
  ReportItem.create!(:report_id => @that_report.id, :time => Time.now, :content => content)
end

Then /^that_shift should not be late$/ do
   @that_shift.should_not be_late
end

Then /^that_shift should be late$/ do
  @that_shift.should be_late
end

Then /^my shift report should have ([0-9]+) comment$/ do |count|
  @shift = @current_user.shifts[0]
  @shift.report.report_items.count.should == count.to_i
end

Then /^the current time should appear$/ do
  response.should contain(Time.now.to_s(:twelve_hour))
end

Then /^"([^\"]*)" should have "([^\"]*)" shift$/ do |name, count|
  user = User.find(:first, :conditions => {:first_name => name.split.first, :last_name => name.split.last})
  if count == "one"
    Shift.find_by_user_id(user.id).should_not be_nil
  elsif count == "no"
    Shift.find_by_user_id(user.id).should be_nil
  end
end

