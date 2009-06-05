require File.dirname(__FILE__) + '/../spec_helper'

describe Report do
  it "should be valid" do
    Report.new.should be_valid
  end
end
