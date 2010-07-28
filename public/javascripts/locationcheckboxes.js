//location group can check or uncheck all, and is only checked itself when all its locations are checked

jQuery($("#TB_ajaxContent")).ready(function(){

////initialize page
//make location group and department checkboxes appear
    $("input[name^=for_location_group],input[name^=department_wide_locations]").each(function(){
      $(this).css("display", "inline");
    });

//check the location groups if all locations come checked
    $("input[name^='for_locations']").each(function(){
        var loccheck = true;
        $(this).parent().children("input[name^='for_locations']").each(function() {
            if($(this).attr('checked') == false)
                {loccheck = false}
        })
        $(this).parent(name^='for_location_group').children("input[name^='for_location_group']").attr('checked', loccheck)
});



////click responses

//checking the dept box - checks/unchecks everything
    $("#department_wide_locations").click(function(){
				var dept_status = $("#department_wide_locations").attr('checked');
				$("div#all_locations :checkbox").each(function(){
                    $(this).attr('checked', dept_status);
                });
			});
//checking the loc_group - checks/unchecks all locations in the group
    $("input[name^='for_location_group']").click(function(){
			  var locgroup_status = $(this).attr('checked');
			  $(this).siblings('input[type=checkbox]').each(function(){
			      $(this).attr('checked', locgroup_status);
			  });
		});

//checking the location
//if any location in a group is unchecked, uncheck the location group's box
//otherwise all are checked and group should be checked
    $("input[name^='for_locations']").click(function(){
        var loccheck = true;
        $(this).closest('li').children("input[name^='for_locations']").each(function() {
            if($(this).attr('checked') == false)
                {loccheck = false}
        })
        $(this).closest('li').children("input[name^='for_location_group']").attr('checked', loccheck)
});

//if any location group is unchecked, uncheck the dept box
//otherwise all are checked and dept should be checked
    $("input[name^='for_locations'],input[name^=for_location_group]").click(function(){
        var deptcheck = true;
        $("#all_locations").find("input[name^='for_locations']").each(function() {
            if($(this).attr('checked') == false)
                {deptcheck = false}
        })
        $("#department_wide_locations").attr('checked', deptcheck)
});


});

