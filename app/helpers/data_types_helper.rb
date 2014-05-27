module DataTypesHelper  
  def fields_for_data_field(data_field, &block)
    if data_field
      prefix = data_field.new_record? ? 'new' : 'existing'
      fields_for("data_type[#{prefix}_data_field_attributes][]", data_field, &block)
    end
  end
end
