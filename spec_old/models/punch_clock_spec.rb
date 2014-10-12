require File.dirname(__FILE__) + '/../spec_helper'

describe PunchClock do
  it "should be valid" do
    PunchClock.new.should be_valid
  end
end
