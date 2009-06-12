Given /^I have no (.+)$/ do |class_name|
  class_name.classify.constantize.delete_all
end

Then /^I should have ([0-9]+) (.+)$/ do |count, class_name|
  class_name.classify.constantize.count.should == count.to_i
end

When /^I choose to view (.+)$/ do |department|
  visit path_to(department_users_path(@department))
end

Given /^I have a user named "([^\"]*)", department "([^\"]*)", login "([^\"]*)"$/ do |name, department, login|
  d = Department.find_by_name("#{department}") or Department.create!(:name => department)

  u = User.new(:name => name, :login => login)
  u.departments << Department.find_by_name("#{department}")
  u.save!

end

Given /^the user "([^\"]*)" has permissions? "([^\"]*)"$/ do |user_name, permissions|
  user = User.find_by_name(user_name)
  permissions.split(", ").each do |permission_name|
    #user.permissions << Permission.find_by_name(permission_name)
  end
end

Given /^I am "([^\"]*)"$/ do |user_name|
  @user = User.find_by_name(user_name)
  @department = @user.departments[0]
  CASClient::Frameworks::Rails::Filter.fake(@user.login)
  #this seems like a clumsy way to set the department but I can't figure out any other way - wei
  visit departments_path
  click_link @department.name
end

