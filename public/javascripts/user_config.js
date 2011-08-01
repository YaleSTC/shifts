jQuery(document).ready(function() {
//multiple select checkboxes code  

var	dept = $('[class^="header"]'),
    dept2 = "stc",
    child_checkboxes = $('[class='+dept2+'][id^="loc"]'),
    child_checkboxes_checked = $('[class='+dept2+'][id^="loc"][checked="checked"]');

  if(child_checkboxes_checked.length === child_checkboxes.length) {
    $(".header_stc").attr('checked', true);
  } else {
    $(".header_stc").attr('checked', false);
  }

  $('[class^="header"]').click(function(){
    var header_status = $(".header_stc").attr('checked');
    child_checkboxes.each(function(){
       $(this).attr('checked', header_status);
     });
  });

  child_checkboxes.click(function(){
    var child_status = child_checkboxes.attr('checked');
    var child_checkboxes_checked
 	child_checkboxes_checked = 0
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
