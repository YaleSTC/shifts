@get_users_engine = (users) ->
  engine = new Bloodhound 
    datumTokenizer: (d) ->
      arr = Bloodhound.tokenizers.whitespace(d.name)
      arr.push(d.login)
      return arr
    queryTokenizer: Bloodhound.tokenizers.whitespace,
    local: users
  return engine;

