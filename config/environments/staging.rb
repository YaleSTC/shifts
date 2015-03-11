require File.expand_path('../production', __FILE__)

Shifts::Application.configure do
  config.action_mailer.perform_deliveries = false

  # Dummy value for deploy script - change as necessary
  config.action_controller.relative_url_root = ""
  config.action_mailer.default_url_options = { host: "" }
  
end
