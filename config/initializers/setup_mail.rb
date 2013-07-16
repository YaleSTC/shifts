ActionMailer::Base.smtp_settings = {
  :address              => "smtp.gmail.com",
  :port                 => 587,
  :domain               => 'gmail.com',
  :user_name            => 'tammerabiyu@gmail.com',
  :password             => 'tamasama',
  :authentication       => 'plain',
  :enable_starttls_auto => true  }





# ActionMailer::Base.smtp_settings = {
#   :address              => "mail.yale.edu",
#   :port                 => 587,
#   :domain               => "yale.edu",
#   :enable_starttls_auto => true
# }