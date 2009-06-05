require File.dirname(__FILE__) + '/../spec_helper'

describe ReportItem do
  it "should be valid" do
    ReportItem.new.should be_valid
  end
end
