require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe User do
  before(:each) do
# the commented bits below don't work yet. -cmk
#    Department.new(:name => "STC")
    @user = User.new(:name => "Wee Willy", :login => "ww")
#    @user.departments << Department.find_by_name("STC")
#    @user.save!
  end
    it "should have a name" do
      @user.name.should == "Wee Willy"
    end

    it "should have a login" do
      @user.login.should == "ww"
    end

    it "should have a unique login" do

    end

    it "should have a department" do
#      @user.departments == "STC"
    end

end

