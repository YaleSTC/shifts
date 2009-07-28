jQuery(document).ready(function(){
    $("#department_wide_locations").click(function(){
    var check_status = $(this).attr('checked');
        $("ul#notice_ul :checkbox").each(function(){
            $(this).attr('checked', check_status);
        });
    });

    $(".loc_group_checkboxes :checkbox").click(function(){
        var locgroup_status = $(this).attr('checked');
        $(this).siblings('input[type=checkbox]').attr('checked', locgroup_status);
    });

    $("#type_sticky").click(function(){
        $("#start_time_choice_date").attr('checked', false);
        $("#start_time_choice_now, #end_time_choice_indefinite").attr('checked', true);
        $("#start_time_choice_date, #notice_start_time, #notice_start_time-mm, #notice_start_time-dd, #notice_start_time_4i, #notice_start_time_5i, #notice_start_time_7i, #notice_end_time, #end_time_choice_date, #notice_end_time-mm, #notice_end_time-dd, #notice_end_time_4i, #notice_end_time_5i, #notice_end_time_7i").attr("disabled", "disabled");
        $("#time_choices").slideUp();
    });

    $("#type_announcement").click(function(){
        $("#start_time_choice_date, #notice_start_time, #notice_start_time-mm, #notice_start_time-dd, #notice_start_time_4i, #notice_start_time_5i, #notice_start_time_7i, #notice_end_time, #end_time_choice_date, #notice_end_time-mm, #notice_end_time-dd, #notice_end_time_4i, #notice_end_time_5i, #notice_end_time_7i").removeAttr("disabled");
        $("#time_choices").slideDown();
    });
});

