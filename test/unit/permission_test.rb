require 'test_helper'

class PermissionTest < ActiveSupport::TestCase
  def test_should_be_valid
    assert Permission.new.valid?
  end
end
