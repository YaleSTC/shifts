require File.dirname(__FILE__) + '/../spec_helper'

describe TimeSlot do
  it "should be valid" do
    TimeSlot.new.should be_valid
  end
end
