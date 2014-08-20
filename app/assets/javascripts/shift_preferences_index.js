$(document).ready(
  function(){
    $.tablesorter.defaults.widgets = ['zebra'];$("#stats_table").tablesorter({sortList: [[0,0]]});
  }
);