initialize("body");

function initialize(element){
  $(element+' li.click_to_add_new_timeslot').click(function (e) {
    popup_new_timeslot($(this), e, this);
    return false;
  });

  $(element+' li.click_to_add_new_shift').click(function (e) {
    popup_new_shift($(this), e, this);
    return false;
  });

  $(element+' li.click_to_edit_shift').click(function (e) {
    popup_edit_shift($(this), e);
    return false;
  });

  $(element+' li.click_to_edit_timeslot').click(function (e) {
    popup_edit_timeslot($(this), e);
    return false;
  });

  $(element+' a.click_to_delete_repeating_shift').click(function (e) {
    popup_delete_repeating_shift($(this), e);
    return false;
  });

  $(element+' a.click_to_delete_repeating_timeslot').click(function (e) {
    popup_delete_repeating_timeslot($(this), e);
    return false;
  });

    //don't stop links from firing
    // $(element+' li.click_to_edit_timeslot a').click(function (e) {
    //   e.stopPropagation();
    // });
    //
    // $(element+' li.click_to_edit_shift a').click(function (e) {
    //   e.stopPropagation();
    // });

$(element+' li.click_to_edit_shift a.delete_link').click(function (e) {
  e.stopPropagation();
});

$(element+' li.click_to_edit_timeslot a.delete_link').click(function (e) {
  e.stopPropagation();
});

show_visible(element);

}

function popup_new_timeslot(parent_element, e, raw_element){
  $("#tooltip").remove();

  var elementID = parent_element.attr('id');
  var params = elementID.split("_", 2);
    var locationID = params[0].substring(8); //remove "location" from id

    //cursor position magic
    var relX = e.pageX - getXOffset(raw_element);
    var widthPercentage = relX / parent_element.width();
    var date = params[1];

    loading_tooltip(e.pageX, e.pageY);
    $.ajax({data:"calendar=<%= @calendar.nil? ? "true" : @calendar.id %>&location_id="+locationID+"&date="+date+"&xPercentage="+widthPercentage, dataType:'script', type:'get', url:'<%= new_time_slot_path %>', async: false});
  }

  function popup_new_shift(parent_element, e, raw_element){
    $("#tooltip").remove();

    var elementID = parent_element.attr('id');
    var params = elementID.split("_", 2);
    var locationID = params[0].substring(8); //remove "location" from id
    var date = params[1];

    //cursor position magic
    var relX = e.pageX - getXOffset(raw_element);
    var widthPercentage = relX / parent_element.width();

    loading_tooltip(e.pageX, e.pageY);
    $.ajax({data:"calendar=<%= @calendar.nil? ? "true" : @calendar.id %>&location_id="+locationID+"&date="+date+"&xPercentage="+widthPercentage, dataType:'script', type:'get', url:'<%= new_shift_path %>', async: false});
  }

  function popup_edit_timeslot(parent_element, e){
    $("#tooltip").remove();

    var id = parent_element.attr('id').substring(8); //remove "timeslot" from id

    loading_tooltip(e.pageX, e.pageY);
    $.ajax({data:"calendar=<%= @calendar.nil? ? "true" : @calendar.id %>", dataType:'script', type:'get', url:'<%= time_slots_path %>/'+id+'/edit', async: false});
  }

  function popup_edit_shift(parent_element, e){
    $("#tooltip").remove();

    var id = parent_element.attr('id').substring(5); //remove "shift" from id

    loading_tooltip(e.pageX, e.pageY);
    $.ajax({data:"calendar=<%= @calendar.nil? ? "true" : @calendar.id %>", dataType:'script', type:'get', url:'<%= shifts_path %>/'+id, async: false});
  }

  function popup_delete_repeating_shift(parent_element, e){
    $("#tooltip").remove();

    var id = parent_element.attr('id').substring(17); //remove "delete_repeating_" from id

    loading_tooltip(e.pageX, e.pageY);
    $.ajax({data:"calendar=<%= @calendar.nil? ? "true" : @calendar.id %>&delete_options=true", dataType:'script', type:'get', url:'<%= shifts_path %>/'+id, async: false});
  }

  function popup_delete_repeating_timeslot(parent_element, e){
    $("#tooltip").remove();

    var id = parent_element.attr('id').substring(17); //remove "delete_repeating_" from id

    loading_tooltip(e.pageX, e.pageY);
    $.ajax({data:"calendar=<%= @calendar.nil? ? "true" : @calendar.id %>&delete_options=true", dataType:'script', type:'get', url:'<%= time_slots_path %>/'+id+'/edit', async: false});
  }

  function loading_tooltip(x,y){
    $('body').append("<div id='tooltip' style='position: absolute; left:"+x+"px; top:"+y+"px'>Loading...</div>");
  }

  function getXOffset(element){
    var x = 0
    while(element){
      x += element.offsetLeft;
      element = element.offsetParent;
    }
    return x;
  }

  //show all calendars that are currently visible, even after rerender
  function show_visible(element){
    for (calendar_id in calendar_visible) {
      if (calendar_visible[calendar_id] == true) {
        $(element+' .calendar'+calendar_id).show();
      }
      else {
        $(element+' .calendar'+calendar_id).hide();
      }
    }
  }