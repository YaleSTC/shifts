$ ->
	# Ctrl+Enter adds to the report
	$('#new_report_item #item').keydown (e)->
		if e.keyCode is 13 and (e.ctrlKey || e.metaKey)
			$('#report_item_submit').click()
			e.preventDefault()

	$('#report_item_submit').click (e)->
		e.preventDefault()
		form = $(this).closest('form')
		msg = $(form).find('textarea').val()	
		if msg
			token = Math.random().toString(36).substr(2)
			$('#token').val(token)
			form.submit()
			$('#new_report_item')[0].reset()
			$('#all_report_items').append "<tr class='list_report_item' id='#{token}'>
												<td class='timestamp'>#{spinner_tag}</td>
												<td class='report_item_content'>#{msg}</td>
										   </tr>"
			view = $('#dashboard_report_view')
			view.scrollTop view[0].scrollHeight

	if $('#update_notices').length
		freq1 = $('#update_notices').data('frequency')*1000
		setInterval ->
			$.get '/notices/update_message_center'
		, freq1

	if $('#update_tasks').length
		freq2 = $('#update_tasks').data('frequency')*1000
		setInterval ->
			$.get '/tasks/update_tasks'
		, freq2

	if $('#update_report').length
		freq3=$('#update_report').data('frequency')*1000
		setInterval ->
			id=$('#update_report').data('id')
			$.get "/reports/#{id}/update_reports"
		, freq3




