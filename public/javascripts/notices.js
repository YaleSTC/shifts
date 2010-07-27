jQuery($("#TB_ajaxContent")).ready(function(){

    if(($("#page_title").text() != "Notices") && ($("#page_title").text() != "My Dashboard")) {
        $("#advanced_options_div").hide();
        $("#toggle_link").html('Show advanced options');
        $("#toggle_link").show();
    } else {
        $("#advanced_options_div").show();
        $("#toggle_link").show();
    }


    $("#toggle_link").click(function(){
				 		if($(this).css("display")!="none") {
	            $("#toggle_link").html('Show advanced options');
							$("#TB_ajaxContent").animate({ height:'-=' + $("#variable_height_box").outerHeight() }, 300 );
	        	}

	       $("#advanced_options_div").toggle(function(){
       				if ($(this).css("display")!="none") {
				            $("#toggle_link").html('Hide advanced options');
										$("#TB_ajaxContent").animate({ height:'+='+ $("#variable_height_box").outerHeight() }, 300 );
				        }
				});
    });


// TODO some duplication remains between notices.js and locationcheckboxes.js
    $("input[name^='for_location_group']").click(function(){
			  var locgroup_status = $(this).attr('checked');
			  $(this).siblings('input[type=checkbox]').each(function(){
			      $(this).attr('checked', locgroup_status);
			      if(locgroup_status) {
			          $(this).attr('disabled', 'disabled');
			      } else {
			          $(this).removeAttr('disabled');
			      }
			  });
		});


});

jQuery($("#variable_height_box")).ajaxComplete(function(){
	var height_change = $("#variable_height_box").outerHeight();
	if (height_change) {
		height_change+=6;
  $("#TB_ajaxContent").animate({ height:'+='+height_change }, 300 );
}
});

