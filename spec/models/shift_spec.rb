require File.dirname(__FILE__) + '/../spec_helper'

describe Shift do
  it "should be valid" do
    Shift.new.should be_valid
  end
end
