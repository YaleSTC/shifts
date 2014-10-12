# == Schema Information
#
# Table name: loc_groups
#
#  id             :integer          not null, primary key
#  name           :string(255)
#  department_id  :integer
#  view_perm_id   :integer
#  signup_perm_id :integer
#  admin_perm_id  :integer
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  public         :boolean          default(TRUE)
#  active         :boolean          default(TRUE)
#

require 'test_helper'

class LocGroupTest < ActiveSupport::TestCase
  def test_should_be_valid
    assert LocGroup.new.valid?
  end
end
