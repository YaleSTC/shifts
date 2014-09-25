require File.dirname(__FILE__) + '/../spec_helper'

describe PayformSet do
  it "should be valid" do
    PayformSet.new.should be_valid
  end
end
