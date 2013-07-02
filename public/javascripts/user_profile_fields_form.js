function description(type)
{
  var return_value = "";
  if(type == "text_area") return "";
  else
  {
    return_value = "<%= escape_javascript(f.label :values) %><br /><%= escape_javascript(f.text_field :values) %><br /><em><small>";
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


$('.form_right').toggle();