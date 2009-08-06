require File.dirname(__FILE__) + '/../spec_helper'

describe RepeatingEvent do
  it "should be valid" do
    RepeatingEvent.new.should be_valid
  end
end
