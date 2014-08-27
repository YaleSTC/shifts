# == Schema Information
#
# Table name: departments
#
#  id                     :integer          not null, primary key
#  name                   :string(255)
#  admin_permission_id    :integer
#  payforms_permission_id :integer
#  shifts_permission_id   :integer
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#

require 'test_helper'

class DepartmentTest < ActiveSupport::TestCase
  def test_should_be_valid
    assert Department.new.valid?
  end
end
