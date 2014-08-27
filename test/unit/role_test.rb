# == Schema Information
#
# Table name: roles
#
#  id            :integer          not null, primary key
#  name          :string(255)
#  department_id :integer
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#

require 'test_helper'

class RoleTest < ActiveSupport::TestCase
  def test_should_be_valid
    assert Role.new.valid?
  end
end
