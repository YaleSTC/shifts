@data_field_type_description = ($div, type) ->
  if type is 'text_area'
    $div.hide()
  else 
    $div.show()
    $div.children('.data_field_instruction').hide()
    $div.children(".data_field_instruction.#{type}").show()


