# == Schema Information
#
# Table name: emails
#
#  id                :integer          not null, primary key
#  from              :string(255)
#  to                :string(255)
#  last_send_attempt :integer          default(0)
#  mail              :text
#  created_on        :datetime
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#

require 'test_helper'

class EmailTest < ActiveSupport::TestCase
  # Replace this with your real tests.
  test "the truth" do
    assert true
  end
end
