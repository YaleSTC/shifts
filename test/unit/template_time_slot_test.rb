# == Schema Information
#
# Table name: template_time_slots
#
#  id          :integer          not null, primary key
#  location_id :integer
#  template_id :integer
#  day         :integer
#  start_time  :datetime
#  end_time    :datetime
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#

require 'test_helper'

class TemplateTimeSlotTest < ActiveSupport::TestCase
  # Replace this with your real tests.
  test "the truth" do
    assert true
  end
end
