jQuery($("#TB_ajaxContent")).ready(function(){ 
		
    if(($("#page_title").text() != "Notices") && ($("#page_title").text() != "My Dashboard")) {
        $("#advanced_options_div").hide();
        $("#toggle_link").html('Show advanced options');
        $("#toggle_link").show();
    } else {
        $("#advanced_options_div").show();
        $("#toggle_link").show();
    }

		$("input[name^=for_location_group],input[name^=department_wide_locations]").each(function(){
  	  $(this).css("display", "inline");		
		});

    $("#department_wide_locations").click(function(){
				var dept_status = $("#department_wide_locations").attr('checked');
				$("div#all_locations :checkbox").each(function(){
				   $(this).attr('checked', dept_status);
				    if(dept_status) {
				          $(this).attr('disabled', 'disabled');
				      } else {
				          $(this).removeAttr('disabled');
				     }	 	
				 });
			});
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
});
jQuery($("#variable_height_box")).ajaxComplete(function(){
	var height_change = $("#variable_height_box").outerHeight();
	if (height_change) {
		height_change+=6;
  $("#TB_ajaxContent").animate({ height:'+='+height_change }, 300 );
}
});
