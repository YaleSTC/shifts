require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe CASClient do
  it "should bypass CAS" do
    ApplicationController.stub!(CASClient::Frameworks::Rails::Filter)
  end

  @current_user = User.find_by_id(1)
end
#  d = Department.find_by_name("STC") or Department.create!(:name => "STC")
#  u = User.new(:name => "payformadmin", :login => "payformadmin")
#  u.departments << Department.find_by_name("STC")
#  u.save!

# # session[:casfilteruser] = payformadmin


#  ApplicationController.should_receive(:current_user).and_return(u)

