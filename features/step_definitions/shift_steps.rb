Given /^I am not logged into a shift report$/ do
  @current_user = User.find_by_login(session[:cas_user])  
  @current_user.shifts.each do |n|
    n.report == nil
  end      
end

Given /^I am logged into a shift report$/ do
  @current_user = User.find_by_login(session[:cas_user])
  @current_user.shifts.each do |n|
    n.report == nil?
  end
end

