source 'https://rubygems.org'

ruby '2.1.2'

gem 'rails', '3.2.19'
gem 'mysql2'

gem 'jquery-rails'
gem 'jquery-ui-rails'
gem 'jquery-tablesorter'
gem 'jcrop-rails-v2', '~> 0.9.12'

# ldap integration
gem 'ruby-net-ldap', :require => 'net/ldap'

# generate calendar feeds
gem 'icalendar'

# authentication
gem 'authlogic'
gem 'scrypt' # dependency of authlogic, which isn't automatically resolved

# image upload
gem 'paperclip'

# model versioning (used for payform items)
gem 'vestal_versions', git: 'https://github.com/laserlemon/vestal_versions.git'

gem 'htmlentities'

# deliver mail asynchronously
gem 'mail'
gem 'delayed_job_active_record', '~> 4.0.2'
gem 'delayed_job_web', '~> 1.2.9'
gem 'daemons', '~> 1.1.9'

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
  gem 'pry-rails'
  gem 'pry-byebug'
  gem 'letter_opener'
  gem 'faker'
  gem 'better_errors'
  gem 'binding_of_caller' # Enables the REPL in better_errors
end

group :test do
  gem 'cucumber-rails',   '>=0.3.0'
  gem 'database_cleaner', '>=0.5.0'
  gem 'webrat',           '>=0.7.0'
  gem 'rspec',            '>=1.3.0'
  gem 'rspec-rails',      '>=1.3.2'
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
