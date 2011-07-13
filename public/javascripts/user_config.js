jQuery(document).ready(function() {
  var dept = "STC",
      dept2 = "stc",
      child_checkboxes = $('[id^="loc"]' && '[class='+dept2+']'),
      child_checkboxes_checked = $('[id^="loc"]' && '[checked="true"]' && '[class='+dept2+']'),
      child_checkboxes_length = child_checkboxes.length,
      child_checkboxes_checked_length = child_checkboxes_checked.length;




// Slide toggle stuff, ignore for now
//  $(document).ready(function() {
  //  $('[name="STC"]').click(function(){
    //  $('[id^="loc"]').slideToggle();
   // });
 // });
 
  if(child_checkboxes_checked_length === child_checkboxes_length) {
    $(".header_stc").attr('checked', true);
  } else {
    $(".header_stc").attr('checked', false);
  }

  $('[class^="header"]').click(function(){
				  var header_status = $(".header_stc").attr('checked');
				  $('[id^="loc"]' && '[class='+dept2+']').each(function(){
				     $(this).attr('checked', header_status);
				      if(header_status) {
				            $(this).attr('checked', true);
				        } else {
				            $(this).attr('checked', false);
				       }	 	
				   });
  });
  var child_checkboxes_checked = $('[id^="loc"]' && '[checked="true"]' && '[class='+dept2+']');
  child_checkboxes.click(function(){
    if(child_checkboxes_checked.length === child_checkboxes.length) {
      $(".header_stc").attr('checked', true);
    } else {
      $(".header_stc").attr('checked', false);
    }
  });

//  child_checkboxes.click(function(){
//    if (child_checkboxes.attr('checked'))
//  })
		  console.log(child_checkboxes_length, child_checkboxes_checked_length, child_checkboxes_checked)
		  console.log(child_checkboxes)
});



