require File.dirname(__FILE__) + '/../spec_helper'

describe UserProfileField do
  it "should be valid" do
    UserProfileField.new.should be_valid
  end
end
