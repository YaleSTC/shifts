ActionMailer::Base.delivery_method = :smtp
ActionMailer::Base.perform_deliveries = true
ActionMailer::Base.raise_delivery_errors = true
ActionMailer::Base.smtp_settings = {
  :address              => "mail.yale.edu",
  :port                 => 587,
  :domain               => 'yale.edu',
  :enable_starttls_auto => true  }

ActionMailer::Base.default_url_options[:host] = "localhost:3000" 



# ActionMailer::Base.smtp_settings = {
#   :address              => "mail.yale.edu",
#   :port                 => 587,
#   :domain               => "yale.edu",
#   :enable_starttls_auto => true
# }