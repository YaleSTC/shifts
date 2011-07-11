# Be sure to restart your server when you modify this file

# Specifies gem version of Rails to use when vendor/rails is not present
RAILS_GEM_VERSION = '2.3.12' unless defined? RAILS_GEM_VERSION

# Bootstrap the Rails environment, frameworks, and default configuration
require File.join(File.dirname(__FILE__), 'boot')

Rails::Initializer.run do |config|

  #HAS_MANY_POLYMORPHS will create a folder generated_models to show you what is going on:
  #ENV["HMP_DEBUG"] = 'true'

  # Settings in config/environments/* take precedence over those specified here.
  # Application configuration should go into files in config/initializers
  # -- all .rb files in that directory are automatically loaded.
  # See Rails::Configuration for more options.


  # Configure Rails Mail options
  config.action_mailer.delivery_method = :smtp
  config.action_mailer.smtp_settings = {
    :address => "mail.yale.edu",
    :port => 587,
    :domain => "yale.edu",

    #for some reason, :authentication => login is not working
    #thus, for now, the server will have to be connected to the yale network
    #to be able to send emails
  }
#  config.action_mailer.raise_delivery_errors = true
  config.action_mailer.default_charset = "utf-8"

  # Specify gems that this application depends on.
  # They can then be installed with "rake gems:install" on new installations.
  # You have to specify the :lib option for libraries, where the Gem name (sqlite3-ruby) differs from the file itself (sqlite3)
  
  # Only load the plugins named here, in the order given. By default, all plugins
  # in vendor/plugins are loaded in alphabetical order.
  # :all can be used as a placeholder for all plugins not explicitly named
  # config.plugins = [ :exception_notification, :ssl_requirement, :all ]

  # Add additional load paths for your own custom dirs
  # config.load_paths += %W( #{RAILS_ROOT}/extras )

  # Force all environments to use the same logger level
  # (by default production uses :info, the others :debug)
  # config.log_level = :debug

  # Make Time.zone default to the specified zone, and make Active Record store time values
  # in the database in UTC, and return them converted to the specified local zone.
  # Run "rake -D time" for a list of tasks for finding time zone names. Comment line to use default local time.
  config.time_zone = 'Eastern Time (US & Canada)'

  # Activate observers that should always be running
  # Please note that observers generated using script/generate observer need to have an _observer suffix
  config.active_record.observers = :user_observer, :department_observer
end

CASClient::Frameworks::Rails::Filter.configure(
  :cas_base_url => "https://secure.its.yale.edu/cas/",
  :username_session_key => :cas_user,
  :extra_attributes_session_key => :cas_extra_attributes
)

if "irb" == $0
  ActiveRecord::Base.logger = Logger.new(STDOUT)
end
