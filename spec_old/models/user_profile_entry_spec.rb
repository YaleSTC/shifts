require File.dirname(__FILE__) + '/../spec_helper'

describe UserProfileEntry do
  it "should be valid" do
    UserProfileEntry.new.should be_valid
  end
end
