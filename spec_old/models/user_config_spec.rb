require File.dirname(__FILE__) + '/../spec_helper'

describe UserConfig do
  it "should be valid" do
    UserConfig.new.should be_valid
  end
end
