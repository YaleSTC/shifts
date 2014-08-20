$(document).ready(
  function(){
    $.tablesorter.defaults.widgets = ['zebra'];
    $("#user_list").tablesorter({sortList: [[2,0]]});
  }
);