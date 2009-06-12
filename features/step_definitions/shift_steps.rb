Given /^I am logged into apps with netid "(.+)" in department "(.+)"$/ do |login, department|
  @current_user =  User.import_from_ldap("login", "department", true)
end

Given /^I am not logged into a shift report$/ do
  @current_user.shifts.reports == nil?
end

