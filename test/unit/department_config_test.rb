# == Schema Information
#
# Table name: department_configs
#
#  id                   :integer          not null, primary key
#  department_id        :integer
#  schedule_start       :integer
#  schedule_end         :integer
#  time_increment       :integer
#  grace_period         :integer
#  auto_remind          :boolean          default(TRUE)
#  auto_warn            :boolean          default(TRUE)
#  mailer_address       :string(255)
#  monthly              :boolean          default(FALSE)
#  end_of_month         :boolean          default(FALSE)
#  day                  :integer          default(6)
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#  weekend_shifts       :boolean
#  unscheduled_shifts   :boolean
#  printed_message      :text
#  reminder_message     :text
#  warning_message      :text
#  warning_weeks        :integer
#  description_min      :integer
#  reason_min           :integer
#  can_take_passed_sub  :boolean          default(TRUE)
#  stats_mailer_address :string(255)
#  stale_shift          :boolean          default(TRUE)
#  payform_time_limit   :integer
#  admin_round_option   :integer          default(15)
#  early_signin         :integer          default(60)
#  task_leniency        :integer          default(60)
#  search_engine_name   :string(255)      default("Google")
#  search_engine_url    :string(255)      default("http://www.google.com/search?q=")
#  default_category_id  :integer
#

require 'test_helper'

class DepartmentConfigTest < ActiveSupport::TestCase
  # Replace this with your real tests.
  test "the truth" do
    assert true
  end
end
