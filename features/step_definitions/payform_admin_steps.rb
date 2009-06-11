Given /^I am a payform administrator$/ do
  #this needs to be changed once we have payform administrator role/permission
  session[:casfilteruser] = payformadmin


    applicationController.should_receive(:current_user).and_return("payformadmin")

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

      mewling = Payform.create!(:date => d , :department_id => @department_id, :user_id => u, :submitted => s, :approved => a, :printed => p)
      print mewling
    end
end

Then /^I should see "([^\"]*)" under "([^\"]*)"$/ do |arg1, arg2|
  pending
end

