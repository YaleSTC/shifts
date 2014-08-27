# == Schema Information
#
# Table name: punch_clock_sets
#
#  id            :integer          not null, primary key
#  description   :string(255)
#  department_id :integer
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#

require 'test_helper'

class PunchClockSetTest < ActiveSupport::TestCase
  # Replace this with your real tests.
  test "the truth" do
    assert true
  end
end
