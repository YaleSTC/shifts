# == Schema Information
#
# Table name: sub_requests
#
#  id              :integer          not null, primary key
#  start           :datetime
#  end             :datetime
#  mandatory_start :datetime
#  mandatory_end   :datetime
#  reason          :text
#  shift_id        :integer
#  user_id         :integer
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#

require 'test_helper'

class SubRequestTest < ActiveSupport::TestCase
  # Replace this with your real tests.
  test "the truth" do
    assert true
  end
end
