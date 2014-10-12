# == Schema Information
#
# Table name: user_profiles
#
#  id                 :integer          not null, primary key
#  user_id            :integer
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#  photo_file_name    :string(255)
#  photo_content_type :string(255)
#  photo_file_size    :integer
#  photo_updated_at   :datetime
#  crop_x             :integer
#  crop_y             :integer
#  crop_h             :integer
#  crop_w             :integer
#

require File.dirname(__FILE__) + '/../spec_helper'

describe UserProfile do
  it "should be valid" do
    UserProfile.new.should be_valid
  end
end
