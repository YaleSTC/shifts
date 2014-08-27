# == Schema Information
#
# Table name: payform_sets
#
#  id            :integer          not null, primary key
#  department_id :integer
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#

require File.dirname(__FILE__) + '/../spec_helper'

describe PayformSet do
  it "should be valid" do
    PayformSet.new.should be_valid
  end
end
