Given /^I have a user named "([^\"]*)" in the department "([^\"]*)" with login "([^\"]*)"$/ do |name, department, login|
  user = User.new(:login => login, :name => name)
  user.departments << Department.find_by_name(department)
  user.save!
end

Given /^that I am a superuser$/ do

  d = Department.find_by_name("STC") or Department.create!(:name => "STC")
  @current_user = User.new(:name => "payformadmin", :login => "payformadmin")
  @current_user.departments << Department.find_by_name("STC")
  @current_user.save!

 # session[:casfilteruser] = payformadmin
  Department.should_receive(:current_user).and_return(@current_user)
end


#  Department.new(:name => "testing ground")
#  user = @current_user
#  user = User.new(:login => "studcomp", :name => "test")
#  user.departments << Department.find_by_name("testing ground")
#  user.save!
#  user.is_superuser? == true

