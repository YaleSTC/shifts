Given /^I have a payform for the week "([^\"]*)"$/ do |week|
  date = week.to_date
  @payform = Payform.create!(:date => date,
                             :user_id => @user.id,
                             :department_id => @department.id)
end

Given /^I have the following payform items?$/ do |table|
  table.hashes.each do |row|
    category = Category.find_by_name(row[:category])
    user = User.find_by_login(row[:user_login])
    payform = @payform ? @payform.id : nil
    PayformItem.create!(:category_id => category.id,
                    :user_id => user.id,
                    :hours => row[:hours].to_f,
                    :description => row[:description],
                    :date => Time.parse(row[:date]),
                    :payform_id => payform)
  end
end

Given /^I have the following payforms?:$/ do |table|
  table.hashes.each do |row|

    date = row[:date].to_date
    department = Department.find_by_name(row[:department])
    user = User.find(:first, :conditions => {:first_name => row[:user_first], :last_name => row[:user_last]})
    submitted = row[:submitted] == "true" ? Time.now - 180 : nil
    approved = row[:approved] == "true" ? Time.now - 120 : nil
    approval = row[:approved] == "true" ? @user : nil
    printed = row[:printed] == "true" ? Time.now - 60 : nil

    Payform.create!(:date => date , :department_id => department.id,
                    :user_id => user.id, :submitted => submitted,
                    :approved => approved, :approved_by => approval,
                    :printed => printed)
  end
end

Then /^payform item ([0-9]+) should be a child of payform item ([0-9]+)$/ do |id_1, id_2|
  payform_item_1 = PayformItem.find(id_1.to_i)
  payform_item_2 = PayformItem.find(id_2.to_i)
  payform_item_2.payform_item_id.should == payform_item_1.id
end

Then /^the payform should be submitted$/ do
  @user.payforms.first.submitted.should_not be_nil
end

Then /^I should see "([^\"]*)" under "([^\"]*)" in column ([0-9]+)$/ do |expected_message, header, column|
  assert_select("table") do
    assert_select("tr th:nth-of-type(#{column.to_i})", header)
    assert_select("tr td:nth-of-type(#{column.to_i})", expected_message)
  end
end

Then /^"([^\"]*)" should have ([0-9]+) (.+)$/ do |name, count, object|
  user = User.find(:first, :conditions => {:first_name => name.split.first, :last_name => name.split.last})
  user.send(object.pluralize).should have(count.to_i).objects
end

Then /^I should have a pdf with "([^\"]*)" in it$/ do |text|
    PDF::Inspector.parse(Prawn::PdfObject(text, true)).should == text
end

