require File.dirname(__FILE__) + '/../spec_helper'

describe AppConfig do
  it "should be valid" do
    AppConfig.new.should be_valid
  end
end
