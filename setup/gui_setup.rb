require 'ftools'
class Setup < Shoes
  @@delivery_method = ''
  @@mail_settings = {}
  @@CAS_Settings = {}
  @@using_cas = false
  url '/', :welcome
  url '/smtp', :smtp
  url '/sendmail', :sendmail
  url '/authentication', :authentication
  url '/review', :review
  url '/done', :done

  def hash_to_string(hash, brackets)
    if hash.nil?
      " "
    elsif brackets
      "{\n"+hash.collect{|k,v| ":#{k} => \"#{v}\","}.join("\n").chomp(',')+"\n}\n"
    else
      "\n"+hash.collect{|k,v| ":#{k} => \"#{v}\","}.join("\n").chomp(',')+"\n"
    end
  end

  def writefiles(delivery_method, mail_settings, auth_settings, using_cas)
    File.rename('config/environment.rb', 'config/environment.rb.backup')

    newtext=File.open('config/environment.rb.backup','r').collect.join()

    if newtext =~ /delivery_method = .*/
      newtext.gsub!(/delivery_method = .*/, "delivery_method = :#{delivery_method}")
    else
      newtext+="\nconfig.action_mailer.delivery_method = :#{delivery_method}"
    end

    if newtext =~ /action_mailer[.][\S]*_settings.*?\}/m
      newtext.gsub!(/action_mailer[.][\S]*_settings.*?\}/m, "action_mailer.#{delivery_method}_settings = #{hash_to_string(mail_settings, true)}")
    else
      newtext += "\nconfig.action_mailer.#{delivery_method}_settings = #{hash_to_string(mail_settings, true)}"
    end

    if using_cas
      if newtext =~ /CASClient::Frameworks::Rails::Filter[.]configure\(/
        newtext.gsub!(/CASClient::Frameworks::Rails::Filter[.]configure\(.*?\)/m, "CASClient::Frameworks::Rails::Filter.configure(#{hash_to_string(auth_settings, false)})\n")
      else
        newtext += "\nCASClient::Frameworks::Rails::Filter.configure(#{hash_to_string(auth_settings, false)})\n"
      end
    end

    out = File.new('config/environment.rb', "w")
    out.puts(newtext)
    out.close
  end

  def welcome
    stack do
      title "Welcome to the App!", align: 'center'

    para "Thank you for using our application!  This script is designed to help you set up some important configuration files. Click the button below to get started!"
    para "To begin, please select what type of mail you\'ll be using. SMTP is recommended."
    flow do
      button ("SMTP") {visit '/smtp'}
      button("sendmail") {visit '/sendmail'}
      end

    end
  end

  def smtp
    @@delivery_method = 'smtp'
    @main_box = stack width: '100%' do
      inscription link("Start Over", click: '/')
      title "SMTP Settings", align: 'center'
      flow{
      para "Please input your smpt server address: "
      @server_box=edit_line text: "mail.example.com"}
      flow{
      para "Please input your smpt server port: "
      @port_box=edit_line text: "444"}
      flow{
      para "If your server has a HELO domain, provide it (optional): "
      @domain_box=edit_line text: "example.com"}
      @submit_button = button("Continue"){@@mail_settings = {
             address: @server_box.text,
             port: @port_box.text}
             @@mail_settings.store(:domain, @domain_box.text) if @domain_box && @domain_box.text
             @@mail_settings.store(:authentication, @auth_box.text) if @auth_box && @auth_box.text
             @@mail_settings.store(:user_name, @username_box.text) if @username_box && @username_box.text
             @@mail_settings.store(:password, @pword_box.text) if @pword_box && @pword_box.text
          visit '/authentication'}
        end
        @optional = stack{ button("Push here if your mail server requires authentication"){@main_box.before(@submit_button) do
          flow{
          para "Provide the authentication type: "
          @auth_box=edit_line text: "login"}
          flow{
          para "Provide your mail server username: "
          @username_box=edit_line text: "login"}
          flow{
          para "Provide your mail server password: "
          @pword_box=edit_line text: "password"}
         end
      @optional.clear
      }}
  end

  def sendmail
    @@delivery_method = 'sendmail'
    stack width: '100%' do
      inscription link("Start Over", click: '/')
      title "Sendmail Settings", align: 'center'
      flow{
      para "Provide the location of the sendmail executable: "
      @location_box=edit_line text: "/usr/sbin/sendmail"}
      flow{
      para "Provide your executable\'s command-line arguments: "
      @arg_box=edit_line text: "-i -t"}
      button ("Continue"){@@mail_settings = {
             location: @location_box.text,
             arguments: @arg_box.text
             }
          visit '/authentication'}
    end

  end

  def authentication
    stack width: '100%' do
      inscription link("Start Over", click: '/')
      title "CAS Settings", align: 'center'
      @main_stack = stack {
      para "Are you planning on using CAS as one of your authentication types?"
      flow do
        button ("Yes"){@@using_cas=true
        @main_stack.clear {stack {
          flow{
          para "Provide the base URL of your CAS server: "
          @server_box=edit_line text: ""}
          flow{
          para "Provide the name your CAS server uses to refer to users: "
          @user_box=edit_line text: "cas_user"}
          flow{
          para "Provide the name your CAS server users to refer to extra attributes: "
          @extra_box=edit_line text: "cas_extra_attributes"}
          flow{
          para "Provide the name your CAS logger: "
          @logger_box=edit_line text: "cas_logger"}
          button("Continue"){@@CAS_Settings= {
            cas_base_url: @server_box.text,
            username_session_key: @user_box.text,
            extra_attributes_session_key: @extra_box.text,
            logger: @logger_box.text
          }
          visit '/review'

          }
            }

          }
        }
        button ("No"){@@using_cas=false; visit '/review'}


        end
}
    end
  end

  def review
    stack width: '100%' do
      inscription link("Start Over", click: '/')
      title "Review", align: 'center'
      subtitle "Here\'s what you\'ve entered:"
      flow { stack width: '45%' do para "Type of mail: "+@@delivery_method
      para "Mail settings:"+hash_to_string(@@mail_settings, false)
    end
      stack width: '45%' do para "Using CAS: "+@@using_cas.to_s
        para "CAS settings: "+hash_to_string(@@CAS_Settings, false) if @@using_cas
    end
      }
      para "Are you sure everything\'s ok?"
      flow{
      button ("No, take me back!"){visit '/'}
      button ("Yup, go ahead and write the files"){
        writefiles(@@delivery_method, @@mail_settings, @@CAS_Settings, @@using_cas)
        visit '/done'
        }
      }
    end

  end

  def done
    stack width: '100%' do
      title "All Done"
      para "You might want to check your environment.rb file and make sure it\'s still ok..."
      button ("click here to exit"){exit}
    end
  end


end

Shoes.app width: 600, height: 600


#puts "\nThank you for using our application!  This script is designed to help you set your configuration action_mailer.  These action_mailer are things that you will probably never need to change, though if you do, all you need to do is run this script again.  If the script should fail for any reason, no changes will be saved; this prevents half-configured applications.  You will need to know a few parameters, namely the action_mailer for your mail server and your CAS (Central Authentication Service) server (if you plan on using CAS.)\n\n"
#puts "Note that this script saves changes to your config/environment.rb and config/initializers/login_action_mailer.rb files.  If you need to manually adjust any of these settings, you can directly edit those files, though caution is advised.  You can also run this script again to reconfigure.  But a word of warning:if you run this script after your initial deployment, there is a possibility that you will break some aspects of your application.  Your database should still be intact (so you won't lose any data), but you may run into other problems.\n\n"
#puts "NOTE: After running this script, you will need to restart your server before any changes will take effect.  The process for doing this varies depending on your exact deployment method.  Consult your deployment instructions or ask your favorite Rails developer if you have any difficulties.\n\n"
#puts "And as with all things, feel free to ask the developers if you have trouble!  The original team can be contacted via our git repository at http://www.github.com/Smudge/newstc, and we'll be happy to try and answer any questions posted to the wiki or issues tracker there or emailed to us personally.\n\n"
#puts "For optional parameters, just hit enter if you don't want to set them."

#  puts "MAILER CONFIGURATION"
#  action_mailer = {}
#  puts "Provide your mail delivery method (smtp, sendmail, or test; smtp is recommended)"
#  action_mailer.store(:delivery_method, gets.chomp)
#  p action_mailer[:delivery_method]
#  if action_mailer[:delivery_method] == 'smtp'
#    action_mailer.store(:settings, {})
#    puts "Provide your smtp server address"
#    action_mailer[:settings].store(:address, gets.chomp)
#    puts "Provide your smtp server's port"
#    action_mailer[:settings].store(:port, gets.chomp)
#    puts "If your server has a HELO domain, provide it (optional)"
#    action_mailer[:settings].store(:domain, gets.chomp)
#    puts "If your mail server requires authentication, provide the authentication type (optional)"
#    action_mailer[:settings].store(:authentication, gets.chomp)
#    unless action_mailer[:settings][:authentication].empty?
#      puts "Provide your mail server username"
#      action_mailer[:settings].store(:user_name, gets.chomp)
#      puts "Provide your mail server password"
#      action_mailer[:settings].store(:password, gets.chomp)
#    end
#  elsif action_mailer[:delivery_method] == "sendmail"
#    action_mailer.store(:settings, {})
#    puts "Provide the location of the sendmail executable (default is /usr/sbin/sendmail)"
#    action_mailer[:settings].store(:location, gets.chomp)
#    puts "Provide your sendmail executable's command-line arguments (default is '-i -t')"
#    action_mailer[:settings].store(:arguments, gets.chomp)
#  end

#  puts "AUTHENTICATION CONFIGURATION"
#  authentication = {}
#  puts "This application has the ability to internally authenticate users (via the authlogic plugin), or to externally direct users to a CAS server (via the rubycas plugin).  You can also enable department administrators to select whether they wish to use one or both of these methods.  Which authentication types do you want to be available to admins?  Please provide 0 for CAS, 1 for internal authentication, or 2 for both."
#  authtypes = gets.chomp.to_i
#  if authtypes == 0 || authtypes == 2
#    puts "Provide the base URL of your CAS server"
#    authentication.store(:cas_base_url, gets.chomp)
#    puts "Provide the name your CAS server uses to refer to users (default is cas_user)"
#    authentication.store(:username_session_key, gets.chomp)
#    puts "Provide the name your CAS server users to refer to extra attributes (default is cas_extra_attributes)"
#    authentication.store(:extra_attributes_session_key, gets.chomp)
#    puts "Provide the name of your CAS server's logger (default is cas_logger)"
#    authentication.store(:logger, gets.chomp)
#  end






##  %x{rake load_fixtures}
#  puts "penguins"



##  config.action_mailer.delivery_method = :smtp
##  config.action_mailer.smtp_settings = {
##    address: "mail.yale.edu",
##    port: 587,
##    domain: "yale.edu",
##    user_name: '',
##    password: '',
##    authentication: ''

##    #for some reason, authentication: login is not working
##    #thus, for now, the server will have to be connected to the yale network
##    #to be able to send emails
##  }


##CASClient::Frameworks::Rails::Filter.configure(
##  cas_base_url: "https://secure.its.yale.edu/cas/",
##  username_session_key: :cas_user,
##  extra_attributes_session_key: :cas_extra_attributes,
##  logger: cas_logger
##)
