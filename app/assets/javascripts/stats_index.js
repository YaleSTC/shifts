$(document).ready(function(){
  $('#user_click').click(function(){
    $('#user_slide').slideToggle(); return false;
  })
  $('#location_click').click(function(){
    $('#location_slide').slideToggle(); return false;
  })
});

$(document).ready(function(){$.tablesorter.defaults.widgets = ['zebra'];$("#user_stats_table").tablesorter({sortList: [[0,0]]});$("#location_stats_table").tablesorter({sortList: [[0,0]]});});

// var opts = {
// formElements:{"stat_start_date_3i":"j",
//                "stat_start_date_1i":"Y",
//                "stat_start_date_2i":"n"
//              },
// statusFormat:"l-cc-sp-d-sp-F-sp-Y",
//              noFadeEffect:true,
//       };
// datePickerController.createDatePicker(opts);

// var opts = {
// formElements:{"stat_end_date_3i":"j",
//                "stat_end_date_1i":"Y",
//                "stat_end_date_2i":"n"
//              },
// statusFormat:"l-cc-sp-d-sp-F-sp-Y",
//              noFadeEffect:true,
// };
// datePickerController.createDatePicker(opts);
