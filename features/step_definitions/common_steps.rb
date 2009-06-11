Given /^I have no (.+)$/ do |class_name|
  class_name.classify.constantize.delete_all
end

Then /^I should have ([0-9]+) (.+)$/ do |count, class_name|
  class_name.classify.constantize.count.should == count.to_i
end

When /^I choose to view (.+)$/ do |department|
  visit path_to(department_users_path(@department))
end

Given /^I have a user named "([A-Za-z]+)", department "(.+)", login "(.+)"$/ do |name, department, login|
  d = Department.find_by_name("#{department}") or Department.create!(:name => department)

  u = User.new(:name => name, :login => login)
  u.departments << Department.find_by_name("#{department}")
  u.save!

end

Given /^I have a user named (.+), login (.+)$/ do |name, login|

  User.create!(:name => name, :login => login)
end

Given /^that CAS is happy$/ do
#  request_login_ticket
#  Department.create!(:name => "test-ground")
#  @current_user = User.new(:login => "studcomp", :name => "Test")
#  @current_user.departments << Department.find_by_name("test-ground")
#  @current_user.is_superuser? == true
#  @current_user.save!
#  User.find_by_login(session[:cas_user])
end

