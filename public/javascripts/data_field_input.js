function description(type)
{
  var return_value = "";
  // <% DataField::DISPLAY_TYPE_OPTIONS.each do |name, value| %>
  // if(type.match("<%= value %>")){
  //   return "<%#= escape_javascript(render :partial => "data_fields/data_field_types/#{value}") %>";
  // }
  // <% end %>
  if(type == "text_area") return "";
  else
  {
    return_value = "<label for=\"data_type_new_data_field_attributes__values\">Values</label><br><input id=\"data_type_new_data_field_attributes__values\" name=\"data_type[new_data_field_attributes][][values]\" size=\"30\" type=\"text\"><br><em><small>";
    if(type == "check_box" || type == "select" || type == "radio_button")
    {
      return_value += "Enter a comma-separated list of choices";
    }
    else if(type == "text_field")
    {
      return_value += "Value should be either 'integer', 'decimal', or 'text'";
    }
    return_value += "</small></em>";
    return return_value;
  }
}