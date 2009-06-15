Given /^I am not logged into a shift report$/ do
  @department = @current_user.departments[0]  
  @current_user.shifts.each do |n|
    n.report == nil
  end
end

Given /^I am logged into a shift report$/ do
  @department = @current_user.departments[0]
  @current_user.shifts.each do |n|
    n.report == nil?
  end
end

