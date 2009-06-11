Given /^I am logged into apps$/ do
  @current_user = User.find_by_netid(1)

end

Given /^I am not logged into a shift report$/ do
  @current_user.shifts.reports == nil?
end

