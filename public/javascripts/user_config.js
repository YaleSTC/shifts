jQuery(document).ready(function() {
//multiple select checkboxes code  

var	header = $('[class^="header"]').not("ul"),
    dept2 = "stc",
    child_checkboxes = $('[class='+dept2+'][id^="loc"]'),
    child_checkboxes_checked = $('[class='+dept2+'][id^="loc"][checked="checked"]');
    
//begin abstracted code
header.each(function(){
  if(child_checkboxes_checked.length === child_checkboxes.length) {
    $(this).attr('checked', true);
  } else {
    $(this).attr('checked', false);
  }
//  $('[class^="header"]').click(function(){
//    var header_status = $(this).attr('checked');
//    child_checkboxes.each(function(){
//       $(this).attr('checked', header_status);
//     });
//  });
});
//end abstracted code


//loading initial state - the header checkbox will be checked iff all of its child checkboxes are checked.
//  if(child_checkboxes_checked.length === child_checkboxes.length) {
//    $(".header_stc").attr('checked', true);
//  } else {
//    $(".header_stc").attr('checked', false);
//  }

//when header checkbox is clicked, change all of its child checkboxes to whatever its checked status is.
  $('[class^="header"]').click(function(){
    var header_status = $(".header_stc").attr('checked');
    child_checkboxes.each(function(){
       $(this).attr('checked', header_status);
     });
  });
//
  child_checkboxes.click(function(){
    var child_checkboxes_checked = 0;
    child_checkboxes.each(function(){
      if($(this).attr('checked')){
        child_checkboxes_checked++;
      }
    if(child_checkboxes_checked === child_checkboxes.length) {
      $(".header_stc").attr('checked', true);
    } else {
      $(".header_stc").attr('checked', false);
    }
    });
  });
	
//Begin header checkboxes toggle slide
	$(".hide").click(function(){
		$(".toggle").slideToggle("fast", function(){
			if($(".toggle").is(":visible")) {
				$(".hide").text("Hide");
			} else {
				$(".hide").text("Show"); 
			}
		});
	});

});
