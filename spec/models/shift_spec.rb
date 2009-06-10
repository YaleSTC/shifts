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
  
  describe "when it has a sub" do
  
    it "should have a user" do
    end
    
    it "should have a sub request" do
    end
    
    it "should be able to be taken" do
    end
    
    describe "when the sub is taken" do
    
      it "should have a different user" do
      end    
      
      it "should no longer have a sub request"
      end
    
    end 
    
  end
  
end
