jQuery($("#TB_ajaxContent")).ready(function(){

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
			  });
		});

//when you click any, see if the children of its parent location group are all checked

    $("input[name^='for_locations']").click(function(){
			  var loc_status = $(this).attr('checked');

if( 'checked' in $(this).siblings('input[type=checkbox]').all.attr('checked')  )
{
alert("yeah")
}

//$(this).siblings('input[type=checkbox]').attr('checked')
//function(){
//			      $(this).attr('checked');  }

			  $(this).siblings('input[type=checkbox]').each(function(){
			      $(this).attr('checked', locgroup_status);
			  });
		});




});

