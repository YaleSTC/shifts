require File.dirname(__FILE__) + '/../spec_helper'

module NoticeHelper
  def valid_notice_attributes
    {
      :author_id => 1,
      :department_id => 1 ,
      :start_time => Time.now ,
      :end_time => nil ,
      :for_locations => 1 ,
      :for_location_groups => 1, 
    }
  end
end

describe Notice do
  include NoticeHelper

  before(:each) do
    @notice = Notice.new
  end

  it "should create a new instance given valid attributes" do
    @notice.attributes = valid_notice_attributes
    @notice.should be_valid
  end
  
  it "should be invalid without valid attributes" do
    @notice.attributes = valid_notice_attributes.except(:start_time)
    @notice.should_not be_valid
  end
  
  it "should have content" do
    @notice.content == nil?
  end
  
  context "when it is a sticky" do
    
    before(:each) do
      @notice = Notice.create(:is_sticky => true)
      @time = Time.now
    end
  
    it "should start now" do
      @notice.start_time == @time
    end
    
    it "should have an indefinite end time" do
      @notice.end_time == nil
    end

  end

end
