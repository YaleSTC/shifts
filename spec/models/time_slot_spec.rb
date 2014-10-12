# == Schema Information
#
# Table name: time_slots
#
#  id                 :integer          not null, primary key
#  location_id        :integer
#  calendar_id        :integer
#  repeating_event_id :integer
#  start              :datetime
#  end                :datetime
#  active             :boolean
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#

require File.dirname(__FILE__) + '/../spec_helper'

describe TimeSlot do
  it "should be valid" do
    TimeSlot.new.should be_valid
  end
end
