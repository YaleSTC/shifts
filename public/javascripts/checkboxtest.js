jQuery(document).ready(function(){

    $("#department_wide_locations").click(function(){
        var check_status = $(this).attr('checked');
        $("ul#notice_ul :checkbox").each(function(){
            $(this).attr('checked', check_status);
        });
    });

    $("div#loc_groups :checkbox").click(function(){
        var locgroup_status = $(this).attr('checked');
        $(this).siblings('input[type=checkbox]').attr('checked', locgroup_status);
    });

    $("#type_is_sticky").click(function(){
        $("#start_time_choice_date").attr('checked', false);
        $("#start_time_choice_now, #end_time_choice_indefinite").attr('checked', true);
        $("#start_time_choice_date, #notice_start_time_1i, #notice_start_time_2i, #notice_start_time_3i, #notice_start_time_4i, #notice_start_time_5i, #notice_end_time_1i, #end_time_choice_date, #notice_end_time_2i, #notice_end_time_3i, #notice_end_time_4i, #notice_end_time_5i").attr("disabled", "disabled");
    });

    $("#type_announcement").click(function(){
        $("#start_time_choice_date, #notice_start_time_1i, #notice_start_time_2i, #notice_start_time_3i, #notice_start_time_4i, #notice_start_time_5i, #notice_end_time_1i, #end_time_choice_date, #notice_end_time_2i, #notice_end_time_3i, #notice_end_time_4i, #notice_end_time_5i").removeAttr("disabled");
    });
/*
    $(".group input[type='checkbox']").each(function(){

            alert("hi?");
        /*$(this).click(function(){
        var check_status = $(this).attr('checked');
        alert(check_status);
        $(this).siblings().attr('checked', check_status);
        });
    });*/

});

