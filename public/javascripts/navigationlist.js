$(document).ready(function() {

	$(function() {

	    var $sidebar   = $("#navigationList"),
	        $window    = $(window),
	        offset     = $sidebar.offset(),
	        topPadding = 0;

	    $window.scroll(function() {
	        if ($window.scrollTop() > offset.top) {
	            $sidebar.stop().animate({
	                marginTop: $window.scrollTop() - offset.top + topPadding
	            });
	        } else {
	            $sidebar.stop().animate({
	                marginTop: 0
	            });
	        }
	    });

	});

});
