//location group can check or uncheck all, and is only checked itself when all its locations are checked

$(document).ready(function(){

////click responses

//checking the dept box - checks/unchecks everything
    $("#department_wide_locations").click(function(){
        var dept_status = $("#department_wide_locations").prop('checked');
		$("div#all_locations :checkbox").each(function(){
            $(this).prop('checked', dept_status);
        });
	});
//checking the loc_group - checks/unchecks all locations in the group
    $("input[name^='for_location_group']").click(function(){
        var locgroup_status = $(this).prop('checked');
        $(this).siblings('input[type=checkbox]').each(function(){
            $(this).prop('checked', locgroup_status);
        });
    });

//checking the location
//if any location in a group is unchecked, uncheck the location group's box
//otherwise all are checked and group should be checked
    $("input[name^='for_locations']").click(function(){
        var loccheck = true;
        $(this).closest('li').children("input[name^='for_locations']").each(function() {
            if($(this).prop('checked') == false)
                {loccheck = false}
        })
        $(this).closest('li').children("input[name^='for_location_group']").prop('checked', loccheck)
});

//if any location group is unchecked, uncheck the dept box
//otherwise all are checked and dept should be checked
    $("input[name^='for_locations'],input[name^=for_location_group]").click(function(){
        var deptcheck = true;
        $("#all_locations").find("input[name^='for_locations']").each(function() {
            if($(this).prop('checked') == false)
                {deptcheck = false}
        })
        $("#department_wide_locations").prop('checked', deptcheck)
});


});

