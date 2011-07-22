jQuery(document).ready(function() {
  var dept = "STC",
      dept2 = "stc",
      child_checkboxes = $('[class='+dept2+'][id^="loc"]'),
      child_checkboxes_checked = $('[class='+dept2+'][id^="loc"][checked="checked"]'),
      child_checkboxes_length = child_checkboxes.length,
      child_checkboxes_checked_length = child_checkboxes_checked.length;

  if(child_checkboxes_checked_length === child_checkboxes_length) {
    $(".header_stc").attr('checked', true);
  } else {
    $(".header_stc").attr('checked', false);
  }

  $('[class^="header"]').click(function(){
    var header_status = $(".header_stc").attr('checked');
    child_checkboxes.each(function(){
       $(this).attr('checked', header_status);
        if(header_status) {
          $(this).attr('checked', true);
        } else {
          $(this).attr('checked', false);
        }	 	
     });
  });

  child_checkboxes.click(function(){
    var child_status = child_checkboxes.attr('checked');
    var child_checkboxes_checked = $('[class='+dept2+'][id^="loc"][checked="checked"]');
    child_checkboxes.each(function(){
      if($(this).attr('checked')){
        child_checkboxes_checked = child_checkboxes_checked.length --;
      } else if(!$(this).attr('checked')){
        child_checkboxes_checked = child_checkboxes_checked.length ++;
      }
    if(child_checkboxes_checked === child_checkboxes.length) {
      $(".header_stc").attr('checked', true);
    } else {
      $(".header_stc").attr('checked', false);
    }

    });
//    child_checkboxes.each(function(){
//      if($(this).attr('checked')) {
//        $(this).attr('checked', false);
//      } else if (!$(this).attr('checked')){
//        $(this).attr('checked', true);
//      }    
//    });
  });

		  console.log(child_checkboxes.length, child_checkboxes_checked.length, child_checkboxes_checked)
		  console.log(child_checkboxes)
});
