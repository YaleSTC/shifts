require 'test_helper'

class LocGroupTest < ActiveSupport::TestCase
  def test_should_be_valid
    assert LocGroup.new.valid?
  end
end
