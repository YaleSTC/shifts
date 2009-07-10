jQuery(document).ready(function(){

    $("#department_wide_locations").click(function(){
        var check_status = $(this).attr('checked');
        $("ul#dept :checkbox").each(function(){
            $(this).attr('checked', check_status);
        });
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

