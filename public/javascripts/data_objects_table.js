$(document).ready(
  function(){
    $(<%= "data_objects_table_#{data_objects_table.first.id}" %>).tablesorter({sortList: [[2,0]]});
  }
);