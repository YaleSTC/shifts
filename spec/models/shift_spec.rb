# == Schema Information
#
# Table name: shifts
#
#  id                  :integer          not null, primary key
#  start               :datetime
#  end                 :datetime
#  active              :boolean
#  calendar_id         :integer
#  repeating_event_id  :integer
#  user_id             :integer
#  location_id         :integer
#  department_id       :integer
#  scheduled           :boolean          default(TRUE)
#  signed_in           :boolean          default(FALSE)
#  power_signed_up     :boolean          default(FALSE)
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#  stats_unsent        :boolean          default(TRUE)
#  stale_shifts_unsent :boolean          default(TRUE)
#  missed              :boolean          default(FALSE)
#  late                :boolean          default(FALSE)
#  left_early          :boolean          default(FALSE)
#  parsed              :boolean          default(FALSE)
#  updates_hour        :decimal(5, 2)    default(0.0)
#

require File.dirname(__FILE__) + '/../spec_helper'

describe Shift do
  it "should be valid" do
    Shift.new.should be_valid
  end
  
  it "should have a user" do
    Shift.user?  
  end
  
  it "should have a start time" do
  end
  
  it "should have an end time" do
  end
    
  
end
