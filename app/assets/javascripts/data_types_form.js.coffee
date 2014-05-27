# Toggle javascript elements
$ ->
	$('#data_fields').show()
	$('.javascript_link').show()
	$('.data_field').each (i) ->
		$value_field = $(this).find('.value_field')
		type = $(this).find(':selected').val()
		data_field_type_description($value_field, type)

