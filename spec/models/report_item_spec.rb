# == Schema Information
#
# Table name: report_items
#
#  id         :integer          not null, primary key
#  report_id  :integer
#  time       :datetime
#  content    :text
#  ip_address :string(255)
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

require File.dirname(__FILE__) + '/../spec_helper'

describe ReportItem do
  
  it "should belong to a report" do
  end
  
  it "should contain content" do
  end
  
end
