# == Schema Information
#
# Table name: punch_clocks
#
#  id                 :integer          not null, primary key
#  description        :string(255)
#  user_id            :integer
#  department_id      :integer
#  runtime            :integer
#  last_touched       :datetime
#  paused             :boolean
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#  punch_clock_set_id :integer
#

require File.dirname(__FILE__) + '/../spec_helper'

describe PunchClock do
  it "should be valid" do
    PunchClock.new.should be_valid
  end
end
