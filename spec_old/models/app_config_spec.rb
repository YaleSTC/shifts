require 'rails_helper'

RSpec.describe AppConfig, type: :model do
  it "should be valid" do
    AppConfig.new.should be_valid
  end
end
