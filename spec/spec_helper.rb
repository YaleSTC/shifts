ENV["RAILS_ENV"] = "test"
require File.expand_path('../../config/environment', __FILE__)

require 'rspec'
require 'capybara/rails'
require 'capybara/rspec'
require 'capybara-screenshot/rspec'


RSpec.configure do |config|
  config.mock_with :rspec
  config.include Capybara::DSL
  config.include FactoryGirl::Syntax::Methods

  config.before(:suite) do
    # The slower truncation strategy is required for DB to be consistent across example groups with Capybara
    DatabaseCleaner.strategy = :truncation
  end
  config.before(:each) do
    DatabaseCleaner.start
    @a_local_time = Time.local(2014, 9, 1, 10, 5, 0)
    Timecop.travel(@a_local_time)
  end
  config.after(:each) do
    Timecop.return
    DatabaseCleaner.clean
  end

  Capybara.asset_host = "http://localhost:3000" # using assets when server is running
  Capybara.javascript_driver = :webkit # WebKit is a lot faster than selenium
  Capybara.default_wait_time = 15 # TravisCI may be slow
end


