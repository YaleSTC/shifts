require File.dirname(__FILE__) + '/../spec_helper'

describe PayformItemSet do
  it "should be valid" do
    PayformItemSet.new.should be_valid
  end
end
