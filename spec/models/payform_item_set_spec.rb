# == Schema Information
#
# Table name: payform_item_sets
#
#  id             :integer          not null, primary key
#  category_id    :integer
#  date           :date
#  hours          :decimal(10, 2)
#  description    :text
#  active         :boolean
#  approved_by_id :integer
#

require File.dirname(__FILE__) + '/../spec_helper'

describe PayformItemSet do
  it "should be valid" do
    PayformItemSet.new.should be_valid
  end
end
