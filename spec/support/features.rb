# spec/support/features.rb
RSpec.configure do |config|
  config.include Features::SessionHelpers, type: :feature
end