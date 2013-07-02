initialize("body");

function initialize(element){
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
}

function popup_new(parent_element, e, raw_element){
  $("#tooltip").remove();

  var elementID = parent_element.attr('id');
  var params = elementID.split("_", 2);
  var locationID = params[0].substring(8); //remove "location" from id

  //cursor position magic
  var relX = e.pageX - getXOffset(raw_element);
  var widthPercentage = relX / parent_element.width();
  var date = params[1];

  loading_tooltip(e.pageX, e.pageY);
  $.ajax({data:"elementID="+elementID+"&location_id="+locationID+"&date="+date+"&xPercentage="+widthPercentage, dataType:'script', type:'get', url:newTimeSlot, async: false});
}

function popup_edit_timeslot(parent_element, e){
  $("#tooltip").remove();

  var id = parent_element.attr('id').substring(8); //remove "timeslot" from id

  loading_tooltip(e.pageX, e.pageY);
  $.ajax({dataType:'script', type:'get', url:timeSlotsPath+'/'+id+'/edit', async: false});
}

function popup_delete_repeating_timeslot(parent_element, e){
  $("#tooltip").remove();

  var id = parent_element.attr('id').substring(17); //remove "delete_repeating_" from id

  loading_tooltip(e.pageX, e.pageY);
  $.ajax({data:"delete_options=true", dataType:'script', type:'get', url:timeSlotsPath+'/'+id+'/edit', async: false});
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

//hide tooltip upon hitting escape
$(document).keypress(
  function (e){
    if (e.which == 0)
    {
      $(".tooltip").remove();
    }
  }
);