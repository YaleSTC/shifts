# Load the rails application
require File.expand_path('../application', __FILE__)

# Version variable
APP_VERSION = `git describe --tags --abbrev=0`.strip unless defined? APP_VERSION

# Initialize the rails application
Shifts::Application.initialize!

# if "irb" == $0
#   ActiveRecord::Base.logger = Logger.new(STDOUT)
# end
