require File.expand_path('../production', __FILE__)

Shifts::Application.configure do
  config.serve_static_assets = true
  config.action_mailer.perform_deliveries = false
  # config.assets.initialize_on_precompile = true
  config.assets.precompile += %w( .js .css *.css.scss .svg .eot .woff .ttf)
  # config.assets.digest = true
  # Dummy value for deploy script - change as necessary
  config.action_controller.relative_url_root = "/stcdev"
  
  # config.assets.compress = false;
  # config.assets.prefix = '/stcdev'

end
