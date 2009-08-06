function description(type)
{
  var return_value = "";
  // <% DataField::DISPLAY_TYPE_OPTIONS.each do |name, value| %>
  // if(type.match("<%= value %>")){
  //   return "<%#= escape_javascript(render :partial => "data_fields/data_field_types/#{value}") %>";
  // }
  // <% end %>
  if(type == "text_area") return "";
  else if(type == "text_field")
    {
      return_value = "<p><label for=\"data_field_upper_alert\">Alerts</label><br/>Upper:<input id=\"data_field_upper_alert\"type=\"text\" size=\"30\" name=\"data_field[upper_alert]\"/><br/>Lower:<input id=\"data_field_lower_alert\" type=\"text\" size=\"30\" name=\"data_field[lower_alert]\"/><br/><small><em>You will receive a warning when a value is above or below these bounds</em></small><em/></p>"
    }
  else if(type == "check_box" || type == "select" || type == "radio_button")
    {
      return_value += "<small><em>Enter a comma-separated list of choices</small></em>";
    }
  }
  return return_value;
}
