require File.dirname(__FILE__) + '/../spec_helper'

describe PayformItem do
  it "should be valid" do
    PayformItem.new.should be_valid
  end
end
