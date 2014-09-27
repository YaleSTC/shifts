ENV["RAILS_ENV"] = "test"
require File.expand_path('../../config/environment', __FILE__)

require 'rspec'
require 'capybara/rails'
require 'casclient'
require 'casclient/frameworks/rails/filter'

RSpec.configure do |config|
  config.mock_with :rspec
  config.include Capybara::DSL
  config.include FactoryGirl::Syntax::Methods
  config.before(:suite) do
    # FactoryGirl.lint
    # %x[bundle exec rake assets:precompile]
    DatabaseCleaner.strategy = :transaction
    DatabaseCleaner.clean_with(:truncation)
  end
  config.around(:each) do |example|
    DatabaseCleaner.cleaning do
      example.run
    end
  end
  Capybara.asset_host = "http://localhost:3000"
end

def sign_in(netid)
  RubyCAS::Filter.fake(netid)
end
