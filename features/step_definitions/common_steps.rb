Given /^I have a user named "([^\"]*)" "([^\"]*)", department "([^\"]*)", login "([^\"]*)"$/ do |first_name, last_name, department, login|
  d = Department.where(:name == "#{department}") or Department.create!(name: department)

  u = User.new(first_name: first_name, last_name: last_name, login: login)
  u.departments << Department.where(:name == "#{department}")
  u.save!
end

Given /^I have a role named "([^\"]*)" with permission "([^\"]*)" in the department "([^\"]*)"$/ do |role, permission, department|
  u = Role.new(name: role, department: Department.where(:name == department))
  u.save!
  Role.where(:name == role).permissions << Permission.where(:name == permission)
end

Given /^the role named "([^\"]*)" has permission "([^\"]*)"$/ do |role, permission|
  Role.where(:name == role).permissions << Permission.where(:name == permission)
end

Given /^the user "([^\"]*)" has permissions? "([^\"]*)"$/ do |name, permissions|
  user = User.find(:first, conditions: {first_name: name.split.first, last_name: name.split.last})
  user.should_not be_nil
  role = Role.where(:name == (permissions + " role")) || Role.new(name: permissions + " role")
  role.department = user.departments.first
  permissions.split(", ").each do |permission_name|
    permission = Permission.where(:name == permission_name)
    permission.should_not be_nil
    role.permissions << Permission.where(:name == permission_name)
  end
  role.save!
  user.roles << role
end

Given /^I am logged into CAS as "([^\"]*)"$/ do |login|
  @current_user = User.where(:login == login)
  @current_user.should_not be_nil
  CASClient::Frameworks::Rails::Filter.fake(login)
end


Given /^I am "([^\"]*)"$/ do |name|
#for some reason cucumber was not seeing this global variable in the app controller.
#remove it at your own peril.
  @appconfig = AppConfig.first
  @current_user = User.find(:first, conditions: {first_name: name.split.first, last_name: name.split.last})
  @current_user.should_not be_nil
  @department = Department.find(@current_user.user_config.default_dept)
  @department.should_not be_nil
  CASClient::Frameworks::Rails::Filter.fake(@current_user.login)
end

Given /^I have no (.+)$/ do |class_name|
  class_name.classify.constantize.delete_all
end

Given /^I have ([0-9]+) (.+)$/ do |count, class_name|
  class_name.classify.constantize.count.should == count.to_i
end

Given /^I have locations "([^\"]*)" in location group "([^\"]*)" for the department "([^\"]*)"$/ do |locations, location_group, department|
  locations.split(", ").each do |location_name|
  loc_group = LocGroup.create!(name: location_group, department_id: Department.where(:name == department).id)
  Location.create!(name: location_name, loc_group_id: loc_group.id,
                   min_staff: 1, max_staff: 3, short_name: location_name,
                   priority: 1)
  end
end

When /^I choose to view (.+)$/ do |department|
  visit path_to(department_users_path(@department))
end

Then /^there should be a shift with user "(.+)" at location "(.+)"$/ do |user, location|
  @user = user
  @location = location
  Shift.where(:user == @user).where(:location == @location)
end

Then /^I should have ([0-9]+) (.+)$/ do |count, class_name|
  class_name.classify.constantize.count.should == count.to_i
end

Then /^I should have no (.+)$/ do |class_name|
  class_name.classify.constantize.count.should == 0
end

Then /^(.+) ([0-9]+) should have attribute "([^\"]*)" "([^\"]*)"$/ do |object, id, attribute, expected|
  object.classify.constantize.find(id.to_i).send(attribute).to_s.should == expected
end



Then /^"([^\"]*)" should have ([0-9]+) (.+)$/ do |name, count, object|
  user = User.find(:first, conditions: {first_name: name.split.first, last_name: name.split.last})
  begin
    user.send(object.pluralize).should have(count.to_i).objects
  rescue
    begin
      obj = user.send(object.singularize)
    rescue
      raise "neither #{object.singularize} nor #{object.pluralize} exist as methods for user"
    end
    if count == 0
      obj.should be_nil
    elsif count
      obj.should_not be_nil
    elsif count > 1
      raise "a user cannot have more than 1 #{object.singularize}"
    end
  end
end

Given /^the user "([^\"]*)" is a superuser$/ do |name|
  user = User.find(:first, conditions: {first_name: name.split.first, last_name: name.split.last})
  user.update_attributes!(superuser: true, supermode: true)
end

