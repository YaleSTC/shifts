require File.dirname(__FILE__) + '/../spec_helper'

describe Restriction do
  it "should be valid" do
    Restriction.new.should be_valid
  end
end
