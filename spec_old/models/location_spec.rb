require File.dirname(__FILE__) + '/../spec_helper'

describe Location do
  it "should be valid" do
    Location.new.should be_valid
  end
end
