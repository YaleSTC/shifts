require File.dirname(__FILE__) + '/../spec_helper'

describe UserProfile do
  it "should be valid" do
    UserProfile.new.should be_valid
  end
end
