@set_up_autocomplete = (data) ->
  $ ->
    $('input.autocomplete').tokenInput data, 
      theme: "facebook"
      hintText: "Type to search for names and logins"
      preventDuplicates: true

