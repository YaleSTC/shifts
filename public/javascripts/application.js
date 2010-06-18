// Place your application-specific JavaScript functions and classes here
// This file is automatically included by javascript_include_tag :defaults

//Don't load anything before the document is ready. (This should work okay, but if not ask Nathan for some workarounds)
$(document).ready(function() {
    // If javascript is enabled, anything with the class 'no_js' will be hidden
    $('.no_js').hide();
    
    //$('#day_#{day.to_s}').slideToggle('200')
    
    // When any form with the class "onchange_submit" is altered, the form gets submitted.
    $('.onchange_submit').change(function() { $
        (this).submit() 
    });


    //Anything of class "trigger" will cause something of class "toggle" with the same name to be toggled
    //Also, the trigger will gain the class "triggered" in case any styling needs to be changed on the trigger
	$("[class^=trigger-]").click(function(){
		$($(this).toggleClass("triggered").attr("class").replace("trigger",".toggle")).slideToggle('200');
	});

});


