# == Schema Information
#
# Table name: restrictions
#
#  id         :integer          not null, primary key
#  starts     :datetime
#  expires    :datetime
#  max_subs   :integer
#  max_hours  :decimal(10, 2)
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

require File.dirname(__FILE__) + '/../spec_helper'

describe Restriction do
  it "should be valid" do
    Restriction.new.should be_valid
  end
end
