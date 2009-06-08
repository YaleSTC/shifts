Given /^I have a user named "([^\"]*)" in the department "([^\"]*)" with login "([^\"]*)"$/ do |name, department, login|
  user = User.new(:login => login, :name => name)
  user.departments << Department.find_by_name(department)
  user.save!
end

Given /^that I am a superuser$/ do
  @current_user = User.find_by_login("studcomp")
end


#  Department.new(:name => "testing ground")
#  user = @current_user
#  user = User.new(:login => "studcomp", :name => "test")
#  user.departments << Department.find_by_name("testing ground")
#  user.save!
#  user.is_superuser? == true

