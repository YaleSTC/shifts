# == Schema Information
#
# Table name: departments_users
#
#  department_id :integer
#  user_id       :integer
#  active        :boolean          default(TRUE)
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  payrate       :decimal(10, 2)
#

require 'test_helper'

class DepartmentsUserTest < ActiveSupport::TestCase
  # Replace this with your real tests.
  test "the truth" do
    assert true
  end
end
