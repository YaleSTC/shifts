@set_up_autocomplete = (id, data) ->
  $ ->
    $("##{id}").tokenInput data, 
      theme: "facebook"
      hintText: "Type to search for names and logins"
      preventDuplicates: true

@autocomplete_add = (id, data) ->
  field = $("##{id}")
  $.each data, (index, user)->
    field.tokenInput "add", user
