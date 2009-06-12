require File.dirname(__FILE__) + '/../spec_helper'

describe Shift do
  it "should be valid" do
    Shift.new.should be_valid
  end
  
  it "should have a user" do
    Shift.user?  
  end
  
  it "should have a start time" do
  end
  
  it "should have an end time" do
  end
    
  
end
