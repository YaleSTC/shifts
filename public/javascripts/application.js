// Place your application-specific JavaScript functions and classes here
// This file is automatically included by javascript_include_tag :defaults

//Don't load anything before the document is ready. (This should work okay, but if not ask Nathan for some workarounds)
$(document).ready(function() {
    // jQuery AJAX helper method:
    $(document).ajaxSend(function(event, request, settings) {
      if (settings.type == 'GET' || settings.type == 'get' || typeof(AUTH_TOKEN) == "undefined") return;
      // settings.data is a serialized string like "foo=bar&baz=boink" (or null)
      settings.data = settings.data || "";
      settings.data += (settings.data ? "&" : "") + "authenticity_token=" + encodeURIComponent(AUTH_TOKEN);
      request.setRequestHeader("Content-Type", "application/x-www-form-urlencoded");
    });
    
    // Any form with id "ajaxed_form" will be AJAXed!!! (needs respond_to format.js in the controller)
    // Prepaer the form to be ajaxed
    // requires jquery.form
    $('.ajaxed_form').ajaxForm({
    dataType: 'script' //by default, evaluates the data returned.
    }); 
    // attach handler to form's submit event 
    $('.ajaxed_form').submit(function() { 
      // submit the form 
      $(this).ajaxSubmit(); 
      // return false to prevent normal browser submit and page navigation 
      return false; 
    });


    // If javascript is enabled, anything with the class 'no_js' will be hidden
    $('.no_js').hide();

    // If javascript is enabled, anything with the class 'no_js' will be hidden
    $('.only_js').show();
    
    // When any form with the class "onchange_submit" is altered, the form gets submitted.
    $('.onchange_submit').change(function() { $
        (this).submit();
    });

    //Anything of class "trigger" will cause the next thing to be toggled. (Use if you have a header directly above the thing it toggles)
    //Also, the trigger will gain the class "triggered" in case any styling needs to be changed on the trigger
	$(".trigger").click(function(){
		$(this).toggleClass("triggered").next().slideToggle('fast');
		event.preventDefault(); //don't actually follow the link/action (even '#' goes to top of page in some cases)
	});  
    //Anything of class "trigger-<id>" will cause something of class "toggle-<id>" with the same <id> to be toggled
    //Also, the trigger will gain the class "triggered" in case any styling needs to be changed on the trigger
	$("[class*=trigger-]").click(function(){
		$(".toggle-"+$(this).toggleClass("triggered").attr("class").match(/trigger-((\w|-)+)\b/)[1]).slideToggle('fast');
		event.preventDefault(); //don't actually follow the link/action (even '#' goes to top of page in some cases)
	});
    //Also, make all triggers links
    $("[class*=trigger]").each(function() {
        $(this).html("<a href='#'>"+$(this).text()+"</a>");
    });

});
