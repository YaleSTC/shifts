jQuery(document).ready(function() {
//multiple select checkboxes code  

var	header = $('[class^="header"]').not("ul"),
		header_no_label = $('[class^="header"]').not("ul, label");

//begin abstracted code - WORKING

header_no_label.each(function(){
	var header_id = $(this).attr("id"),
			child_checkboxes = $('[class='+header_id+'][id^="loc"]'),
			child_checkboxes_checked = $('[class='+header_id+'][id^="loc"][checked="checked"]');
//loading initial state - the header checkbox will be checked iff all of its child checkboxes are checked.

  if(child_checkboxes_checked.length === child_checkboxes.length) {
    $(this).attr('checked', true);
  } else {
    $(this).attr('checked', false);
  }
});

header.each(function(){
	var header_id = $(this).attr("id"),
			header_instance = $(this),
			child_checkboxes = $('[class='+header_id+'][id^="loc"]'),
			child_checkboxes_checked = $('[class='+header_id+'][id^="loc"][checked="checked"]');
  $(this).click(function(){
    var header_status = $(this).attr('checked');
    child_checkboxes.each(function(){
       $(this).attr('checked', header_status);
     });
  });
	child_checkboxes.click(function(){
	  var child_checkboxes_checked = 0;
	  child_checkboxes.each(function(){
	    if($(this).attr('checked')){
	      child_checkboxes_checked++;
	    } if(child_checkboxes_checked === child_checkboxes.length) {
	    	$(header_instance).attr('checked', true);
	  	} else {
	    	$(header_instance).attr('checked', false);
	  	}
	  });
	});
	
	//begin WORK IN PROGRESS code
//Begin header checkboxes toggle slide


});

var hide_class = $('[class^="header"][id="hide"]');
hide_class.each(function(){
	var hide_class_name = $(this).attr("class"),
			ul_class = $('[class='+hide_class_name+'][id="ul"]'),
			hide_class_instance = $(this);
	$(this).click(function(){
		ul_class.slideToggle("fast", function(){
			if(ul_class.is(":visible")) {
				hide_class_instance.text("Hide");
			} else {
				hide_class_instance.text("Show"); 
			}
		});
	});
});

//end abstracted code
});
