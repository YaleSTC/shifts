require File.expand_path('../boot', __FILE__)

require 'rails/all'

# If you have a Gemfile, require the gems listed there, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(:default, Rails.env) if defined?(Bundler)

module Shifts
  class Application < Rails::Application
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    # Custom directories with classes and modules you want to be autoloadable.
    # config.autoload_paths += %W(#{config.root}/extras)

    # Only load the plugins named here, in the order given (default is alphabetical).
    # :all can be used as a placeholder for all plugins not explicitly named.
    # config.plugins = [ :exception_notification, :ssl_requirement, :all ]

    # Activate observers that should always be running.
    # config.active_record.observers = :cacher, :garbage_collector, :forum_observer

    # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
    # Run "rake -D time" for a list of tasks for finding time zone names. Default is UTC.
    # config.time_zone = 'Central Time (US & Canada)'

    # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
    # config.i18n.load_path += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}').to_s]
    # config.i18n.default_locale = :de

    # JavaScript files you want as :defaults (application.js is always included).
    # config.action_view.javascript_expansions[:defaults] = %w(jquery rails)

    # Configure the default encoding used in templates for Ruby 1.9.
    config.encoding = "utf-8"

    # Configure sensitive parameters which will be filtered from the log file.
    config.filter_parameters += [:password]


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

      # Only load the plugins named here, in the order given. By default, all plugins
      # in vendor/plugins are loaded in alphabetical order.
      # :all can be used as a placeholder for all plugins not explicitly named
      # config.plugins = [ :exception_notification, :ssl_requirement, :all ]

      # Add additional load paths for your own custom dirs
      # config.load_paths += %W( #{RAILS_ROOT}/extras )

      # Force all environments to use the same logger level
      # (by default production uses :info, the others :debug)
      # config.log_level = :debug

      config.rubycas.cas_base_url = 'https://secure.its.yale.edu/cas/'

      # Make Time.zone default to the specified zone, and make Active Record store time values
      # in the database in UTC, and return them converted to the specified local zone.
      # Run "rake -D time" for a list of tasks for finding time zone names. Comment line to use default local time.
      config.time_zone = 'Eastern Time (US & Canada)'

      # Activate observers that should always be running
      # Please note that observers generated using script/generate observer need to have an _observer suffix
      config.active_record.observers = :user_observer, :department_observer

  end
end