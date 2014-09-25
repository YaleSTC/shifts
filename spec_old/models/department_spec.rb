require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Department do
  before(:each) do
    @valid_attributes = {
      name: "Valid name"
    }
  end

  it "should create a new instance given valid attributes" do
    Department.create!(@valid_attributes)
  end

  it "should be invalid without name" do
    Department.new.save.should_be_false
  end
end

