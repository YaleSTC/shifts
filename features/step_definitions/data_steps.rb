Given /^I have a data type with name "([^\"]*)", description "([^\"]*)", for the department "([^\"]*)", with the following data fields$/ do |data_type_name, description, department, table|

  data_type = DataType.find_by_name(data_type_name) or DataType.create!(:name => data_type_name, :description => description, :department_id => Department.find_by_name(department).id)

  table.hashes.each do |row|
      DataField.create!(:data_type_id => data_type.id,
                        :name => row[:name],
                        :display_type => row[:display_type],
                        :values => row[:values])
    end
end

Given /^I have a data object of data_type "([^\"]*)", named "([^\"]*)", description "([^\"]*)", in location group "([^\"]*)"$/ do |data_type, name, description, location_group|

  loc_group_id = LocationGroup.find_by_name(location_group).id
  data_type_id = DataType.find_by_name(data_type).id
  data_object = DataObject.create!(:name => name, :description => description, :location_group_id => loc_group_id, :data_type_id => data_type_id)

end

