$(document).ready(function(){$.tablesorter.defaults.widgets = ['zebra'];$("#stats_table").tablesorter({sortList: [[0,1]]});});

  initialize("body");

function initialize(div){

  $(div+' td.click_to_show').click(function (e) {
    popup_show($(this), e);
    return false;
  });

}

function popup_show(parent_element, e){
  $("#tooltip").remove();

  var id = parent_element.attr('id').substring(5); //remove "shift" from id

  loading_tooltip(e.pageX, e.pageY);
  $.ajax({dataType:'script', type:'get', url:'<%= shifts_path %>/'+id, async: false});
  // $.ajax({dataType:'script', type:'get', url:'<%= shifts_path %>/'+id, async: false});
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
