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