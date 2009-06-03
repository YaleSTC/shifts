Given /^I have a department named (.+)$/ do |department|
  @department = Department.create(:name => department)
end
