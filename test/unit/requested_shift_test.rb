# == Schema Information
#
# Table name: requested_shifts
#
#  id               :integer          not null, primary key
#  preferred_start  :datetime
#  preferred_end    :datetime
#  acceptable_start :datetime
#  acceptable_end   :datetime
#  day              :integer
#  template_id      :integer
#  user_id          :integer
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  assigned_start   :datetime
#  assigned_end     :datetime
#

require 'test_helper'

class RequestedShiftTest < ActiveSupport::TestCase
  # Replace this with your real tests.
  test "the truth" do
    assert true
  end
end
