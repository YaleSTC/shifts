<script>
$(document).ready(function() {
  $("ul.event-row li").each(function() {
    var tooltip = $(this).tooltip({
	    tip: $('#tip_'+$(this).attr("id")),
	    events: { def: 'click, error', tooltip: "mouseenter"},
	    delay: 60,
	    position: 'bottom center',
	    api: true
    }); //.dynamic({ bottom: { direction: 'up', bounce: true } });
    
    $('#tip_'+$(this).attr("id")).find(".closetooltip").click(function() {
     if (tooltip.isShown()) {
        tooltip.hide();
        return false;
     }
    });
    $("ul.event-row li").not(this).click(function() {
      if (tooltip.isShown()) {
        tooltip.hide();
     }
    });
    
    //TODO: hide when clicked outside.
    /*$('body').click(function() {
      if (tooltip.isShown()) {
        tooltip.hide();
      }
    });

    $('#tip_'+$(this).attr("id")).click(function(event){
      if (tooltip.isShown()) {
        event.stopPropagation();
      }
    });*/
  });
});
</script>
<style type="text/css">
.tooltip {
	background-color:#000;
	border:1px solid #fff;
	padding:10px 15px;
	width:200px;
  display:none;
	color:#fff;
	text-align:left;
	font-size:12px;
	z-index: 1000;
	-moz-box-shadow:0 0 10px #000;
	-webkit-box-shadow:0 0 10px #000;
	box-shadow:0 0 10px #000;
}
</style>