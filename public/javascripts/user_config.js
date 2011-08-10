jQuery(document).ready(function() {
//Multiple select checkboxes code  

var	header = $('[class^="header"]').not("ul"),
		header_no_label = $('[class^="header"]').not("ul, label");

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

var header_no_label = $("fieldset#child_checkbox_2").children("h3").children('[class^="header"]').not("label");
header_no_label.each(function(){
	var header_id = $(this).attr("id"),
			child_checkboxes_dt = $('[class='+header_id+'][id^="dt"]'),
			child_checkboxes_checked_dt = $('[class='+header_id+'][id^="dt"][checked="checked"]');
	if(child_checkboxes_checked_dt.length === child_checkboxes_dt.length) {
	  $(this).attr('checked', true);
	} else {
	  $(this).attr('checked', false);
	}
});

//change child checkboxes' checked status to whatever the header checkbox's is
header.each(function(){
	var header_id = $(this).attr("id"),
			header_instance = $(this),
			child_checkboxes = $('[class='+header_id+'][id^="loc"]'),
			child_checkboxes_checked = $('[class='+header_id+'][id^="loc"][checked="checked"]'),
			child_checkboxes_dt = $('[class='+header_id+'][id^="dt"]'),
			child_checkboxes_checked_dt = $('[class='+header_id+'][id^="dt"][checked="checked"]');
  $(this).click(function(){
    var header_status = $(this).attr('checked');
    child_checkboxes.each(function(){
       $(this).attr('checked', header_status);
     });
  });
  $(this).click(function(){
    var header_status = $(this).attr('checked');
    child_checkboxes_dt.each(function(){
       $(this).attr('checked', header_status);
     });
  });
//If all of a header's child checkboxes are checked, then change that header's status to checked. Otherwise, the header should be unchecked.
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
	child_checkboxes_dt.click(function(){
	  var child_checkboxes_checked_dt = 0;
	  child_checkboxes_dt.each(function(){
	    if($(this).attr('checked')){
	      child_checkboxes_checked_dt++;
	    } if(child_checkboxes_checked_dt === child_checkboxes_dt.length) {
	    	$(header_instance).attr('checked', true);
	  	} else {
	    	$(header_instance).attr('checked', false);
	  	}
	  });
	});

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
		return false;
	});
});
});