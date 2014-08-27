# == Schema Information
#
# Table name: user_configs
#
#  id                     :integer          not null, primary key
#  user_id                :integer
#  default_dept           :integer
#  view_loc_groups        :string(255)
#  view_week              :string(255)
#  watched_data_objects   :string(255)
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#  taken_sub_email        :boolean          default(TRUE)
#  send_due_payform_email :boolean          default(TRUE)
#

require File.dirname(__FILE__) + '/../spec_helper'

describe UserConfig do
  it "should be valid" do
    UserConfig.new.should be_valid
  end
end
