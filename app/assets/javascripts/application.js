//= require jquery
//= require jquery_ujs
//= require bootstrap
// jquery.ui.all
//= require jquery-tablesorter
//= require jquery.Jcrop
//= require hoverIntent
//= require thickbox-compressed
//= require bootstrap-hover-dropdown
//= require_tree .

//Don't load anything before the document is ready.
$(document).ready(function() {

    // When any form with the class "onchange_submit" is altered, the form gets submitted.
    $('.onchange_submit').change(function() { $
        (this).submit();
    });

    //Anything of class "trigger" will cause the next thing to be toggled. (Use if you have a header directly above the thing it toggles)
    //Also, the trigger will gain the class "triggered" in case any styling needs to be changed on the trigger
	$(".trigger").click(function(){
		$(this).toggleClass("triggered").next().slideToggle('fast');
		event.preventDefault(); //don't actually follow the link/action (even '#' goes to top of page in some cases)
	});

    //Anything of class "trigger-<id>" will cause something of class "toggle-<id>" with the same <id> to be toggled
    //Also, the trigger will gain the class "triggered" in case any styling needs to be changed on the trigger
	$("[class*=trigger-]").click(function(){
		$(".toggle-"+$(this).toggleClass("triggered").attr("class").match(/trigger-((\w|-)+)\b/)[1]).slideToggle('fast');
		event.preventDefault(); //don't actually follow the link/action (even '#' goes to top of page in some cases)
	});

    //Also, make all triggers links
    $("[class*=trigger]").each(function() {
      $(this).html("<a href='#'>"+$(this).text()+"</a>");
    });

    $("#announcement_link").click(function(e){
      var modal = $("#modal"), modalBody = $("#modal .modal-body");

      modal.on("show.bs.modal", function(){
        modalBody.load(e.currentTarget.href);
        $("#modal .modal-title").html($("#announcement_link").text());
      }).modal();
      e.preventDefault();
    });

    // Tooltips
    var elems_for_tooltip = [$(".notice a.close"), $(".notice #edit")];
    $(elems_for_tooltip).each(function(){
      $(this).tooltip({
        container: 'body'
      });
    });

});
