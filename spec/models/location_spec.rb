# == Schema Information
#
# Table name: locations
#
#  id           :integer          not null, primary key
#  name         :string(255)
#  short_name   :string(255)
#  useful_links :text
#  max_staff    :integer
#  min_staff    :integer
#  priority     :integer
#  report_email :string(255)
#  active       :boolean
#  loc_group_id :integer
#  template_id  :integer
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  description  :string(255)
#  category_id  :integer
#

require File.dirname(__FILE__) + '/../spec_helper'

describe Location do
  it "should be valid" do
    Location.new.should be_valid
  end
end
