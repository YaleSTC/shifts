# == Schema Information
#
# Table name: sub_requests
#
#  id              :integer          not null, primary key
#  start           :datetime
#  end             :datetime
#  mandatory_start :datetime
#  mandatory_end   :datetime
#  reason          :text
#  shift_id        :integer
#  user_id         :integer
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#

require File.dirname(__FILE__) + '/../spec_helper'

describe SubRequest do

  it "should have a shift" do 
  end
  
  it "should have a reason" do
  end
  
  it "should have a user" do
  end
  
  describe "when it is taken" do
  
    it "should become a shift" do
    end

  end
end
