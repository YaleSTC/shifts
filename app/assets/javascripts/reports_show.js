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
		var freq1=$('#update_notices').data('frequency')*1000;
		setInterval(function(){
			$.get('/notices/update_message_center');
		},freq1);
	};
	if ($('#update_tasks').length) {
		var freq2=$('#update_tasks').data('frequency')*1000;
		setInterval(function(){
			$.get('/tasks/update_tasks');
		},freq2);
	};
	if ($('#update_report').length) {
		var freq3=$('#update_report').data('frequency')*1000;
		setInterval(function(){
			var id=$('#update_report').data('id');
			$.get('/reports/'+id+'/update_reports');
		}, freq3);
	};

});
