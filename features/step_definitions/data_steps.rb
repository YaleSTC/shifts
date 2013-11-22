Given /^I have a data type with name "([^\"]*)", description "([^\"]*)", for the department "([^\"]*)", with the following data fields$/ do |data_type_name, description, department, table|

  data_type = DataType.create!(name: data_type_name,
                               description: description,
                               department_id: Department.find_by_name(department).id)

  table.hashes.each do |row|
      DataField.create!(data_type_id: data_type.id,
                        name: row[:name],
                        display_type: row[:display_type],
                        values: row[:values])
    end
end

Given /^I have a data object of data_type "([^\"]*)", named "([^\"]*)", description "([^\"]*)", in location "([^\"]*)"$/ do |data_type, name, description, location|

  data_type_id = DataType.find_by_name(data_type).id
  data_object = DataObject.new(name: name, description: description, data_type_id: data_type_id)
  data_object.locations << Location.find_by_name(location)
  data_object.save!

end

When /^I select "([^\"]*)" as the "([^\"]*)"$/ do |value, field_name|
  select(value)
end

When /^I put "([^\"]*)" in "([^\"]*)"$/ do |value, field_name|
  field = "data_fields_"+ DataField.find_by_name(field_name).id.to_s + "_" + field_name
  fill_in(field, with: value)
end

