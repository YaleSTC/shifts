function DepartmentCheckBoxes(){
	var dept_status = $("#department_wide_locations").attr('checked');
	if(dept_status) {
		$("div#all_locations :checkbox").each(function(){
			$(this).attr('checked', dept_status);
		});
	  $(this).attr('disabled', 'disabled');
	} else {
		$(this).removeAttr('disabled');
	}
}

function LocGroupCheckBoxes(lcg){
	lcg.each(function(){
		var locgroup_status = $(this).attr('checked');
		if(locgroup_status) {
			$(this).siblings('input[type=checkbox]').each(function(){
		    $(this).attr('checked', locgroup_status);
			});
			$(this).attr('disabled', 'disabled');
		} else {
		  $(this).removeAttr('disabled');
		}
	});
}

jQuery(document).ready(function(){
//By default, only have advanced_options open on the main Notices and Dashboard page (not in a shift report page)
//This disables all checkboxes under the department checkbox if the department checkbox is checked
//		DepartmentCheckBoxes();
		LocGroupCheckBoxes($("input[name^='for_location_group']"));
		
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
		
    $("#department_wide_locations").click(DepartmentCheckBoxes);
    //Tried and failed to extract this to a seperate function. Could not get objects to pass correctly. TODO: for someone with more javascript skillz -bay
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
	       $("#advanced_options_div").toggle(function(){
       		 if($(this).css("display")=="none") {
		            $("#toggle_link").html('Show advanced options');
								$("#TB_ajaxContent").animate({ height:'-=240' }, 300 );
		        } else {
		            $("#toggle_link").html('Hide advanced options');
								$("#TB_ajaxContent").animate({ height:'+=240' }, 300 );
		        }
				});
    });
});
