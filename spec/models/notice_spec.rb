# == Schema Information
#
# Table name: notices
#
#  id              :integer          not null, primary key
#  sticky          :boolean          default(FALSE)
#  useful_link     :boolean          default(FALSE)
#  announcement    :boolean          default(FALSE)
#  indefinite      :boolean
#  content         :text
#  author_id       :integer
#  start           :datetime
#  end             :datetime
#  department_id   :integer
#  remover_id      :integer
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  url             :string(255)
#  type            :string(255)
#  department_wide :boolean
#

require File.dirname(__FILE__) + '/../spec_helper'

module NoticeHelper
  def valid_notice_attributes
    {
      author_id: 1,
      remover_id: 1,
#      department:  Department.find_by_name("STC"),
#      department_wide: true,
      department_id: 1,
      is_sticky: false,
      start_time: Time.now ,
      end_time: Time.now + (60 * 60 * 24),
      created_at: Time.now - (60 * 60 * 24),
#      for_users: User.all ,
      content: "Test content",
#      for_locations: 1,
#      for_location_groups: 1
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
  
  it "should be invalid without content" do
    @notice.attributes = valid_notice_attributes.except(:content)
    @notice.should_not be_valid
  end
  
  it "should have content" do
    @notice.content == nil?
  end
  
  context "when it is a sticky" do
    
    before(:each) do
      @notice = Notice.new(is_sticky: true)
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
