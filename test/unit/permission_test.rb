# == Schema Information
#
# Table name: permissions
#
#  id         :integer          not null, primary key
#  name       :string(255)
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

require 'test_helper'

class PermissionTest < ActiveSupport::TestCase
  def test_should_be_valid
    assert Permission.new.valid?
  end
end
