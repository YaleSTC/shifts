require File.dirname(__FILE__) + '/../spec_helper'

describe Cagtegory do
  it "should be valid" do
    Cagtegory.new.should be_valid
  end
end
