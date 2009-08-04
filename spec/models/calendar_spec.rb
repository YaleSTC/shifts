require File.dirname(__FILE__) + '/../spec_helper'

describe Calendar do
  it "should be valid" do
    Calendar.new.should be_valid
  end
end
