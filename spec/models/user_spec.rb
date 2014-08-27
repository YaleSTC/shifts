# == Schema Information
#
# Table name: users
#
#  id                    :integer          not null, primary key
#  login                 :string(255)
#  first_name            :string(255)
#  last_name             :string(255)
#  nick_name             :string(255)
#  employee_id           :string(255)
#  email                 :string(255)
#  crypted_password      :string(255)
#  password_salt         :string(255)
#  persistence_token     :string(255)
#  auth_type             :string(255)
#  perishable_token      :string(255)      default(""), not null
#  default_department_id :integer
#  created_at            :datetime         not null
#  updated_at            :datetime         not null
#  superuser             :boolean
#  supermode             :boolean          default(TRUE)
#  calendar_feed_hash    :string(255)
#

require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe User do
  before(:each) do
# the commented bits below don't work yet. -cmk
#    Department.new(name: "STC")
    @user = User.new(name: "Wee Willy", login: "ww")
#stubbing CAS?
#     controller.stub!(CASClient::Frameworks::Rails::Filter).and_return(true)
#    @user.departments << Department.find_by_name("STC")
#    @user.save!
  end
    it "should have a name" do
      @user.name.should == "Wee Willy"
    end

    it "should have a login" do
      @user.login.should == "ww"
    end

    it "should have a unique login"

    it "should have a department"
#      @user.departments == "STC"

end

