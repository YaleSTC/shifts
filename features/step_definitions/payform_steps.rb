Given /^I have a payform for the week "([^\"]*)"$/ do |week|
  date = week.to_date
  @current_user.should_not be_nil
  @payform = Payform.build(@current_user.departments.first, @current_user, date)
  @payform.should_not be_new_record
end

Given /^I have the following payform items?$/ do |table|
  table.hashes.each do |row|
    category = Category.find_by_name(row[:category])
    user = User.find_by_login(row[:user_login])
    date = Date.parse(row[:date])
    payform = Payform.build(user.departments.first, user, date)

    PayformItem.create!(category_id: category.id,
                    user_id: user.id,
                    hours: row[:hours].to_f,
                    description: row[:description],
                    date: date,
                    payform_id: payform.id)
  end
end

Given /^I have the following payforms?:$/ do |table|
  table.hashes.each do |row|

    date = row[:date].to_date

    department = Department.find_by_name(row[:department])
    period_date = Payform.default_period_date(date, department)
    user = User.find(:first, conditions: {first_name: row[:user_first], last_name: row[:user_last]})

    submitted = row[:submitted] == "true" ? period_date + 2 : nil
    approved = row[:approved] == "true" ? Time.now - 120 : nil
    approval = row[:approved] == "true" ? @current_user : nil
    printed = row[:printed] == "true" ? Time.now - 60 : nil

    Payform.create!(date: period_date , department_id: department.id,
                    user_id: user.id, submitted: submitted,
                    approved: approved, approved_by: approval,
                    printed: printed)
  end
end

When /^I check off "([^\"]*)"$/ do |name|
  user = User.find(:first, conditions: {first_name: name.split.first, last_name: name.split.last})
  field = "user_ids[" + user.id.to_s + "]"
  check(field)
end

Given /^"([^\"]*)" has an unsubmitted payform from "([^\"]*)" weeks ago with 1 payform_item$/ do |name, count|
  date = Payform.default_period_date(count.to_i.weeks.ago.to_date, @department)

  user = User.find(:first, conditions: {first_name: name.split.first, last_name: name.split.last})

  Payform.create!(date: date ,
                  department_id: @department.id,
                  user_id: user.id)
  PayformItem.create!(category_id: Category.find(1),
                      user_id: user.id,
                      hours: 1,
                      description: "He did things. We are not sure what exactly",
                      date: date,
                      payform_id: Payform.find_by_date(date).id)
end

Then /^payform item ([0-9]+) should be a child of payform item ([0-9]+)$/ do |id_1, id_2|
  payform_item_1 = PayformItem.find(id_1.to_i)
  payform_item_2 = PayformItem.find(id_2.to_i)
  payform_item_2.parent_id.should == payform_item_1.id
end

Then /^the payform should be submitted$/ do
  @payform = Payform.find(@payform)
  @payform.submitted.should_not be_nil
end

Then /^I should see "([^\"]*)" under "([^\"]*)" in column ([0-9]+)$/ do |expected_message, header, column|
  assert_select("table") do
    assert_select("tr th:nth-of-type(#{column.to_i})", header)
    assert_select("tr td:nth-of-type(#{column.to_i})", expected_message)
  end
end

Then /^that payform_item should be inactive$/ do
  PayformItem.first.active.should be_false
end

Then /^"([^\"]*)" should have one payform item$/ do |name|
  user = User.find(:first, conditions: {first_name: name.split.first, last_name: name.split.last})
  PayformItem.find_by_user_id(user.id).should_not be_nil
end

