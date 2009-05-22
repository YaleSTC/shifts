require 'test_helper'

class DepartmentTest < ActiveSupport::TestCase
  def test_should_be_valid
    assert Department.new.valid?
  end
end
