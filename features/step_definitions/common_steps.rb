Given /^I have a user named "([^\"]*)" "([^\"]*)", department "([^\"]*)", login "([^\"]*)"$/ do |first_name, last_name, department, login|
  d = Department.find_by_name("#{department}") or Department.create!(:name => department)

  u = User.new(:first_name => first_name, :last_name => last_name, :login => login)
  u.departments << Department.find_by_name("#{department}")
  u.save!
end

Given /^the user "([^\"]*)" has permissions? "([^\"]*)"$/ do |name, permissions|
  user = User.find(:first, :conditions => {:first_name => name.split.first, :last_name => name.split.last})
  user.should_not be_nil
  permissions.split(", ").each do |permission_name|
    dept = Department.create!(:name => permission_name.split(" dept admin").to_s)
    user.departments << dept

    role = Role.new(:name => permissions + " role")
    role.departments << dept
    role.permissions << Permission.find_by_name(permission_name)
    role.save!
    user.roles << role
  end
end

Given /^I am "([^\"]*)"$/ do |name|
  @user = User.find(:first, :conditions => {:first_name => name.split.first, :last_name => name.split.last})
  @user.should_not be_nil
  @department = @user.departments.first
  CASClient::Frameworks::Rails::Filter.fake(@user.login)
#    #this seems like a clumsy way to set the department but I can't figure out any other way - wei
  visit departments_path
  click_link @department.name

end

Given /^I have no (.+)$/ do |class_name|
  class_name.classify.constantize.delete_all
end

Given /^I have ([0-9]+) (.+)$/ do |count, class_name|
  class_name.classify.constantize.count.should == count.to_i
end

Given /^I have locations "([^\"]*)" in location group "([^\"]*)" for the department "([^\"]*)"$/ do |locations, location_group, department|
  locations.split(", ").each do |location_name|
  loc_group = LocGroup.create!(:name => location_group, :department_id => Department.find_by_name(department).id)
  Location.create!(:name => location_name, :loc_group_id => loc_group.id,
                   :min_staff => 1, :max_staff => 3, :short_name => location_name,
                   :priority => 1)
  end
end

When /^I choose to view (.+)$/ do |department|
  visit path_to(department_users_path(@department))
end

Then /^there should be a shift with user "(.+)" at location "(.+)"$/ do |user, location|
  @user = user
  @location = location
  Shift.find_by_user(@user).find_by_location(@location)
end

Then /^I should have ([0-9]+) (.+)$/ do |count, class_name|
  class_name.classify.constantize.count.should == count.to_i
end

Then /^I should have no (.+)$/ do |class_name|
  class_name.classify.constantize.count.should == 0
end

