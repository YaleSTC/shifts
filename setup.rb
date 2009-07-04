require 'ftools'

def hash_to_string(hash, brackets)
  if hash.nil?
    " "
  elsif brackets
    "{\n"+hash.collect{|k,v| ":#{k} => \"#{v}\","}.join("\n").chomp(',')+"\n}\n"
  else
    "\n"+hash.collect{|k,v| ":#{k} => \"#{v}\","}.join("\n").chomp(',')+"\n"
  end
end



puts "\nThank you for using our application!  This script is designed to help you set your configuration action_mailer.  These action_mailer are things that you will probably never need to change, though if you do, all you need to do is run this script again.  If the script should fail for any reason, no changes will be saved; this prevents half-configured applications.  You will need to know a few parameters, namely the action_mailer for your mail server and your CAS (Central Authentication Service) server (if you plan on using CAS.)\n\n"
puts "Note that this script saves changes to your config/environment.rb and config/initializers/login_action_mailer.rb files.  If you need to manually adjust any of these settings, you can directly edit those files, though caution is advised.  You can also run this script again to reconfigure.  But a word of warning:if you run this script after your initial deployment, there is a possibility that you will break some aspects of your application.  Your database should still be intact (so you won't lose any data), but you may run into other problems.\n\n"
puts "NOTE: After running this script, you will need to restart your server before any changes will take effect.  The process for doing this varies depending on your exact deployment method.  Consult your deployment instructions or ask your favorite Rails developer if you have any difficulties.\n\n"
puts "And as with all things, feel free to ask the developers if you have trouble!  The original team can be contacted via our git repository at http://www.github.com/Smudge/newstc, and we'll be happy to try and answer any questions posted to the wiki or issues tracker there or emailed to us personally.\n\n"
puts "For optional parameters, just hit enter if you don't want to set them."

  puts "MAILER CONFIGURATION"
  action_mailer = {}
  puts "Provide your mail delivery method (smtp, sendmail, or test; smtp is recommended)"
  action_mailer.store(:delivery_method, gets.chomp)
  p action_mailer[:delivery_method]
  if action_mailer[:delivery_method] == 'smtp'
    action_mailer.store(:settings, {})
    puts "Provide your smtp server address"
    action_mailer[:settings].store(:address, gets.chomp)
    puts "Provide your smtp server's port"
    action_mailer[:settings].store(:port, gets.chomp)
    puts "If your server has a HELO domain, provide it (optional)"
    action_mailer[:settings].store(:domain, gets.chomp)
    puts "If your mail server requires authentication, provide the authentication type (optional)"
    action_mailer[:settings].store(:authentication, gets.chomp)
    unless action_mailer[:settings][:authentication].empty?
      puts "Provide your mail server username"
      action_mailer[:settings].store(:user_name, gets.chomp)
      puts "Provide your mail server password"
      action_mailer[:settings].store(:password, gets.chomp)
    end
  elsif action_mailer[:delivery_method] == "sendmail"
    action_mailer.store(:settings, {})
    puts "Provide the location of the sendmail executable (default is /usr/sbin/sendmail)"
    action_mailer[:settings].store(:location, gets.chomp)
    puts "Provide your sendmail executable's command-line arguments (default is '-i -t')"
    action_mailer[:settings].store(:arguments, gets.chomp)
  end

  puts "AUTHENTICATION CONFIGURATION"
  authentication = {}
  puts "This application has the ability to internally authenticate users (via the authlogic plugin), or to externally direct users to a CAS server (via the rubycas plugin).  You can also enable department administrators to select whether they wish to use one or both of these methods.  Which authentication types do you want to be available to admins?  Please provide 0 for CAS, 1 for internal authentication, or 2 for both."
  authtypes = gets.chomp.to_i
  if authtypes == 0 || authtypes == 2
    puts "Provide the base URL of your CAS server"
    authentication.store(:cas_base_url, gets.chomp)
    puts "Provide the name your CAS server uses to refer to users (default is cas_user)"
    authentication.store(:username_session_key, gets.chomp)
    puts "Provide the name your CAS server users to refer to extra attributes (default is cas_extra_attributes)"
    authentication.store(:extra_attributes_session_key, gets.chomp)
    puts "Provide the name of your CAS server's logger (default is cas_logger)"
    authentication.store(:logger, gets.chomp)
  end

  File.rename('config/environment.rb', 'config/environment.rb.backup')

  newtext=File.open('config/environment.rb.backup','r').collect.join()

  if newtext =~ /delivery_method = .*/
    newtext.gsub!(/delivery_method = .*/, "delivery_method = :#{action_mailer[:delivery_method]}")
  else
    newtext+="\nconfig.action_mailer.delivery_method = :#{action_mailer[:delivery_method]}"
  end

  if newtext =~ /action_mailer[.][\S]*_settings.*?\}/m
    newtext.gsub!(/action_mailer[.][\S]*_settings.*?\}/m, "action_mailer.#{action_mailer[:delivery_method]}_settings = #{hash_to_string(action_mailer[:settings], true)}")
  else
    newtext += "\nconfig.action_mailer.#{action_mailer[:delivery_method]}_settings = #{hash_to_string(action_mailer[:settings], true)}"
  end

  if authtypes == 0 || authtypes == 2
    if newtext =~ /CASClient::Frameworks::Rails::Filter[.]configure\(/
      newtext.gsub!(/CASClient::Frameworks::Rails::Filter[.]configure\(.*?\)/m, "CASClient::Frameworks::Rails::Filter.configure(#{hash_to_string(authentication, false)})\n")
    else
      newtext += "\nCASClient::Frameworks::Rails::Filter.configure(#{hash_to_string(authentication, false)})\n"
    end
  end

  out = File.new('config/environment.rb', "w")
  out.puts(newtext)
  out.close




#  %x{rake load_fixtures}
  puts "penguins"



#  config.action_mailer.delivery_method = :smtp
#  config.action_mailer.smtp_settings = {
#    :address => "mail.yale.edu",
#    :port => 587,
#    :domain => "yale.edu",
#    :user_name => '',
#    :password => '',
#    :authentication => ''

#    #for some reason, :authentication => login is not working
#    #thus, for now, the server will have to be connected to the yale network
#    #to be able to send emails
#  }


#CASClient::Frameworks::Rails::Filter.configure(
#  :cas_base_url => "https://secure.its.yale.edu/cas/",
#  :username_session_key => :cas_user,
#  :extra_attributes_session_key => :cas_extra_attributes,
#  :logger => cas_logger
#)

