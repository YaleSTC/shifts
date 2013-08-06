initialize("body");

function initialize(element) {

  $(element+' td.click_to_show').click(function (e) {
    popup_show($(this), e);
    return false;
  });

  $(element+' li.click_to_add_new').click(function (e) {
    popup_new($(this), e, this);
    return false;
  });

  $(element+' li.click_to_edit_timeslot').click(function (e) {
    popup_edit_timeslot($(this), e);
    return false;
  });

  $(element+' a.click_to_delete_repeating_timeslot').click(function (e) {
    popup_delete_repeating_timeslot($(this), e);
    return false;
  });

  //don't stop links from firing
  $(element+' li.click_to_edit_timeslot a.delete_link').click(function (e) {
    e.stopPropagation();
  });

  $(element+' li.click_to_show').click(function (e) {
    popup_show($(this), e);
    return false;
  });

  $(element+' div.click_to_add_new').click(function (e) {
    popup_generic_new($(this), e);
    return false;
  });

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

  $(element+' li.click_to_edit_shift a.delete_link').click(function (e) {
    e.stopPropagation();
  });

  $(element+' li.click_to_edit_timeslot a.delete_link').click(function (e) {
    e.stopPropagation();
  });

  show_visible(element);
}

function popup_show(parent_element, e){
  $("#tooltip").remove();

  var id = parent_element.attr('id').substring(5); //remove "shift" from id

  loading_tooltip(e.pageX, e.pageY);
  $.ajax({dataType:'script', type:'get', url:shiftsPath+'/'+id});
}

function loading_tooltip(x,y){
  $('body').append("<div id='tooltip' style='position: absolute; left:"+x+"px; top:"+y+"px'>Loading...</div>");
  // make sure that the tooltip doesn't disappear when you click on it
  $("#tooltip").click(function(e){
    e.stopPropagation();
  });
}

function getXOffset(element){
  var x = 0
  while(element){
      x += element.offsetLeft;
      element = element.offsetParent;
  }
  return x;
}

function popup_new(parent_element, e, raw_element){
  $("#tooltip").remove();

  var elementID = parent_element.attr('id');
  var params = elementID.split("_", 2);
  var locationID = params[0].substring(8); //remove "location" from id
  var date = params[1];

  //cursor position magic
  var relX = e.pageX - getXOffset(parent_element.closest('.events').get(0));
  var widthPercentage = relX / parent_element.closest('.events').width();

  loading_tooltip(e.pageX, e.pageY);
  $.ajax({data:"location_id="+locationID+"&date="+date+"&xPercentage="+widthPercentage, dataType:'script', type:'get', url:newShiftPath});
}


function popup_generic_new(parent_element, e){
  $("#tooltip").remove();

  var elementID = parent_element.attr('id');
  var params = elementID.split("_", 2);
  var locationID = params[0].substring(8); //remove "location" from id
  var date = params[1];

  loading_tooltip(e.pageX, e.pageY);
  $.ajax({data:"location_id="+locationID+"&date="+date, dataType:'script', type:'get', url:newShiftPath});
}

function popup_edit_timeslot(parent_element, e){
  $("#tooltip").remove();

  var id = parent_element.attr('id').substring(8); //remove "timeslot" from id

  loading_tooltip(e.pageX, e.pageY);
  $.ajax({dataType:'script', type:'get', url:timeSlotsPath+'/'+id+'/edit'});
}

function popup_delete_repeating_timeslot(parent_element, e){
  $("#tooltip").remove();

  var id = parent_element.attr('id').substring(17); //remove "delete_repeating_" from id

  loading_tooltip(e.pageX, e.pageY);
  $.ajax({data:"delete_options=true", dataType:'script', type:'get', url:timeSlotsPath+'/'+id+'/edit'});
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
  $.ajax({data:"calendar="+calendar+"&location_id="+locationID+"&date="+date+"&xPercentage="+widthPercentage, dataType:'script', type:'get', url:newTimeSlotPath});
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
  $.ajax({data:"calendar="+calendar+"&location_id="+locationID+"&date="+date+"&xPercentage="+widthPercentage, dataType:'script', type:'get', url:newShiftPath});
}

function popup_edit_shift(parent_element, e){
  $("#tooltip").remove();

  var id = parent_element.attr('id').substring(5); //remove "shift" from id

  loading_tooltip(e.pageX, e.pageY);
  $.ajax({data:"calendar="+calendar, dataType:'script', type:'get', url:shiftsPath+'/'+id});
}

function popup_delete_repeating_shift(parent_element, e){
  $("#tooltip").remove();

  var id = parent_element.attr('id').substring(17); //remove "delete_repeating_" from id

  loading_tooltip(e.pageX, e.pageY);
  $.ajax({data:"calendar="+calendar+"&delete_options=true", dataType:'script', type:'get', url:shiftsPath+'/'+id});
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

//hide tooltip upon hitting escape
$(document).keypress(
  function (e){
    if (e.which == 0)
    {
      $(".tooltip").remove();
    }
  }
);

//close window when pressing [esc]
$(this).keyup(function(event) {
  if (event.keyCode == 27) {
     $('#tooltip').fadeOut(function (){ $(this).remove() });
   return false;
   }
});
//close window when clicking on the page
$(this).click(function(event) {
  if ($('#tooltip').length == 1) {
    $('#tooltip').fadeOut(function (){ $(this).remove() });
    return(false);
  }
});

var calendar_visible = {};

//Hide the new timeslot link when Javascript it enabled
$('#new_time_slot_link').toggle();



// For the stats pages 
$(document).ready(function(){$.tablesorter.defaults.widgets = ['zebra'];$("#stats_table").tablesorter({sortList: [[1,0],[0,1]]});});

var opts = {
                formElements:{"stat_start_date_3i":"j",
                              "stat_start_date_1i":"Y",
                              "stat_start_date_2i":"n"
                },
                statusFormat:"l-cc-sp-d-sp-F-sp-Y",
                noFadeEffect:true,
                       };
datePickerController.createDatePicker(opts);

var opts = {
                formElements:{"stat_end_date_3i":"j",
                              "stat_end_date_1i":"Y",
                              "stat_end_date_2i":"n"
                },
                statusFormat:"l-cc-sp-d-sp-F-sp-Y",
                noFadeEffect:true,
                       };
datePickerController.createDatePicker(opts);