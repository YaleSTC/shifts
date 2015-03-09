@set_up_autocomplete = (id, data, pre) ->
  $ ->
    $("##{id}").tokenInput data, 
      theme: "facebook"
      hintText: "Type to search for names and logins"
      preventDuplicates: true
      prePopulate: pre

@autocomplete_add = (id, data) ->
  field = $("##{id}")
  $.each data, (index, user)->
    field.tokenInput "add", user
