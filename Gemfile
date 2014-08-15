source 'https://rubygems.org'

gem 'rails', '3.2.13'
gem 'mysql2'

gem 'jquery-rails'
gem 'jquery-ui-rails'
gem 'jquery-tablesorter'
gem 'jcrop-rails'

# ldap integration
gem 'ruby-net-ldap', :require => 'net/ldap'

# generate calendar feeds
gem 'icalendar'

# authentication
gem 'authlogic'

# image upload
gem 'paperclip'

# model versioning (used for payform items)
gem 'vestal_versions', git: 'https://github.com/laserlemon/vestal_versions.git'

gem 'htmlentities'

# deliver mail asynchronously
gem 'mail'
gem 'delayed_job_active_record'
gem 'delayed_job_web'
gem 'daemons'

# scheduled cron jobs
gem 'whenever'

# authentication
gem 'rubycas-client-rails'
gem 'rubycas-client', '2.2.1'

# deployment
gem 'capistrano'
gem 'airbrake'

# removed these plugins as they are deprecated
gem 'dynamic_form' # needed for f.error_messages
gem 'simple_form'  # replaces multiple_select
# replace ActiveSupport::Memoizable
gem 'memoist'

group :development do
  # Issue 258: jazz_hands breaks on Ruby 2.0.0+, pry-byebug requires 2.0.0+
  gem 'jazz_hands', platform: [:ruby_19]
  gem 'pry-byebug', platform: [:ruby_20]
  gem 'letter_opener'
  gem 'faker'
  gem 'rack-webconsole-pry', :require => 'rack-webconsole'
end

group :assets do
  #gem 'sass-rails',   '~> 3.2.3' # using sass-rails below
  gem 'coffee-rails', '~> 3.2.1'
  gem 'uglifier', '>= 1.0.3'
end

# For Twitter-bootstrap (also use sass-rails), https://github.com/twbs/bootstrap-sass
gem 'bootstrap-sass', '~> 3.1.1'
# Starting with bootstrap-sass v3.1.1.1, due to the structural changes from upstream you will need these backported asset pipeline gems on Rails 3.2.
gem 'sprockets-rails', '=2.0.0.backport1'
gem 'sprockets', '=2.2.2.backport2'
gem 'sass-rails', github: 'guilleiguaran/sass-rails', branch: 'backport'

