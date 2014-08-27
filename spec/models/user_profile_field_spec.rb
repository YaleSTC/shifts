# == Schema Information
#
# Table name: user_profile_fields
#
#  id            :integer          not null, primary key
#  name          :string(255)
#  display_type  :string(255)
#  values        :string(255)
#  public        :boolean
#  user_editable :boolean
#  department_id :integer
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  index_display :boolean          default(TRUE)
#

require File.dirname(__FILE__) + '/../spec_helper'

describe UserProfileField do
  it "should be valid" do
    UserProfileField.new.should be_valid
  end
end
