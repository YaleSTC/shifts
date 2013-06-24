$('#timer').epiclock({format: 'x:i:s', mode: EC_COUNTUP, 
                      target: '<%= Time.now.to_s(:utc) %>', 
                      offset:{seconds: <%= no_of_sec %>}}); 
jQuery.epiclock(EC_RUN)