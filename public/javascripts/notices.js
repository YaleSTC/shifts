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

});


jQuery($("#variable_height_box")).ajaxComplete(function(){
	var height_change = $("#variable_height_box").outerHeight();
	if (height_change) {
		height_change+=6;
        $("#TB_ajaxContent").animate({ height:'+='+height_change }, 300 );
    }

});

