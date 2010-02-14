$(function()
{
  jQuery('input.date-pick').datePicker({clickInput:true,startDate:'01/01/1996'}).dpSetOffset(22, 0);
});
Date.format = 'mm/dd/yyyy';

$(document).ready(function()
  {
    $$("table.group_shifts").each(function(element){jQuery(element).tablesorter();});
  }
);
jQuery.noConflict();
