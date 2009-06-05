require File.dirname(__FILE__) + '/../spec_helper'

describe SubRequest do
  it "should be valid" do
    SubRequest.new.should be_valid
  end
end
