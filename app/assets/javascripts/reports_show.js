// Ctrl+Enter adds to the report
$(document).ready(function(){
	$('#item').keydown(function (e) {
	  if (e.keyCode === 13 && e.ctrlKey) {
	    $('#report_item_submit').click();
	    e.preventDefault;
	  }
	});

	$('#report_item_submit').click(function () {
	  // $('#report_item_submit').attr('disabled', true);
	  $(this).hide();
	  $('#fake_button').show();
	  return true;
	});
	
	if ($('#update_notices').length) {
		setInterval(function(){
			$.get('/notices/update_message_center');
		},240000);
	}
	if ($('#update_tasks').length) {
		setInterval(function(){
			$.get('/tasks/update_tasks');
		},300000);
	}

});
