jQuery(document).ready(function() {
  var dept = "STC";
  $('[name='+dept+']').click(function() {
    $('[id^="loc"]').attr("checked", true);
  });
});
//  $(document).ready(function() {
  //  $('[name="STC"]').click(function(){
    //  $('[id^="loc"]').slideToggle();
   // });
 // });

