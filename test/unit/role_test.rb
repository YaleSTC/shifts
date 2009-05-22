require 'test_helper'

class RoleTest < ActiveSupport::TestCase
  def test_should_be_valid
    assert Role.new.valid?
  end
end
