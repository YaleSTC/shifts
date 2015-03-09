@get_users_engine = (users) ->
  engine = new Bloodhound 
    datumTokenizer: (d) ->
      arr = Bloodhound.tokenizers.whitespace(d.name)
      arr.push(d.login)
      return arr
    queryTokenizer: Bloodhound.tokenizers.whitespace,
    local: users
  return engine;

$ ->
  $('.autocomplete').on 'tokenfield:createtoken', (event)->
    existing_tokens = $(this).tokenfield 'getTokens'
    $.each existing_tokens, (index, token)->
      if token.value==event.attrs.value
        event.preventDefault()
        
