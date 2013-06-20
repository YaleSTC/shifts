# Add your own tasks in files placed in lib/tasks ending in .rake,
# for example lib/tasks/capistrano.rake, and they will automatically be available to Rake.

require File.expand_path('../config/application', __FILE__)
# Rails 2.3??
#require(File.join(File.dirname(__FILE__), 'config', 'boot'))

require 'rake/dsl_definition'
require 'rake'
include Rake::DSL

Shifts::Application.load_tasks