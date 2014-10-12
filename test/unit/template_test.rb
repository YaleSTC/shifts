# == Schema Information
#
# Table name: templates
#
#  id                   :integer          not null, primary key
#  name                 :string(255)
#  department_id        :integer
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#  public               :boolean
#  max_total_hours      :integer
#  min_total_hours      :integer
#  max_continuous_hours :integer
#  min_continuous_hours :integer
#  max_number_of_shifts :integer
#  min_number_of_shifts :integer
#  max_hours_per_day    :integer
#

require 'test_helper'

class TemplateTest < ActiveSupport::TestCase
  # Replace this with your real tests.
  test "the truth" do
    assert true
  end
end
