# == Schema Information
#
# Table name: user_profile_entries
#
#  id                    :integer          not null, primary key
#  user_profile_id       :integer
#  user_profile_field_id :integer
#  content               :string(255)
#  created_at            :datetime         not null
#  updated_at            :datetime         not null
#

require File.dirname(__FILE__) + '/../spec_helper'

describe UserProfileEntry do
  it "should be valid" do
    UserProfileEntry.new.should be_valid
  end
end
