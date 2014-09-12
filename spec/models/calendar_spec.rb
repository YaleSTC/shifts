require 'rails_helper'

RSpec.describe Calendar, type: :model do
  it "should be valid" do
    Calendar.new.should be_valid
  end
end
