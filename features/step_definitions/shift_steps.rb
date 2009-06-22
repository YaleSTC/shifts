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

Then /^my shift report should have ([0-9]+) comment$/ do |count|
  @shift = @current_user.shifts[0]
  @shift.report.report_items.count.should == count.to_i
end

