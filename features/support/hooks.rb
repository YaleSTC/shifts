#Runs a Mongrel test server
#@appconfig = AppConfig.first
#'mongrel_rails start -e test -p 3001 -P log/mongrel.pid -d'

#Spawns a Celerity Jruby process
#  $server ||= Culerity::run_server
#  $browser = Culerity::RemoteBrowserProxy.new $server, {:browser => :firefox}
#  $browser.webclient.setJavaScriptEnabled(true)
#  @host = 'http://localhost:3001'

#Upon end of testing, stops Celerity Jruby processes and kills Mongrel server
#at_exit do
#  $browser.exit
#  $server.close
#  `mongrel_rails stop -p log/mongrel.pid`
#end

