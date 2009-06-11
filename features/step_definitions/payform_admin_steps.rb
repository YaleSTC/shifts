Given /^I am a payform administrator$/ do
  #this needs to be changed once we have payform administrator role/permission

  d = Department.find_by_name("STC") or Department.create!(:name => "STC")
  @current_user = User.new(:name => "payformadmin", :login => "payformadmin")
  @current_user.departments << Department.find_by_name("STC")
  @current_user.save!

 # session[:casfilteruser] = payformadmin
  Payform.should_receive(:current_user).and_return(@current_user)
end

Given /^I have a category "([^\"]*)"$/ do |category|
  @category = Category.create!(:name => category, :id => 1, :active => true)
end


Given /^I have the following payforms:$/ do |table|
  table.hashes.each do |row|

      d = row[:date]
      u = User.find_by_name(row[:user]).id
      @department_id = DepartmentsUser.find_by_user_id(u).department_id

      row[:submitted] = true ? s = Time.now : s = nil
      row[:approved] = true ? a = Time.now : a = nil
      row[:printed] = true ? p = Time.now : p = nil

      Payform.create!(:date => d , :department_id => @department_id, :user_id => u, :submitted => s, :approved => a, :printed => p)
    end
end

Then /^I should see "([^\"]*)" under "([^\"]*)"$/ do |arg1, arg2|
  pending
end

