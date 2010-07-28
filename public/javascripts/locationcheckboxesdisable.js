//location group can check or uncheck all, disabling them when checked
//

jQuery($("#TB_ajaxContent")).ready(function(){

////initialize page

//make location group and department checkboxes appear
	$("input[name^=for_location_group],input[name^=department_wide_locations]").each(function(){
      $(this).css("display", "inline");
	});



////click responses

//checking the dept box - checks/unchecks everything
//also disables location groups and locations
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

//checking the loc_group - checks/unchecks all locations in the group
//also disables location groups
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

