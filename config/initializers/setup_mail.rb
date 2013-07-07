ActionMailer::Base.smtp_settings = {
  :address              => "mail.yale.edu",
  :port                 => 587,
  :domain               => "yale.edu",
  :enable_starttls_auto => true
}