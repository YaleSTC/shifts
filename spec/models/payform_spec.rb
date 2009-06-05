require File.dirname(__FILE__) + '/../spec_helper'

describe Payform do
  it "should be valid" do
    Payform.new.should be_valid
  end
end
