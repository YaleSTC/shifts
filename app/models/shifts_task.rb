# == Schema Information
#
# Table name: shifts_tasks
#
#  task_id    :integer
#  shift_id   :integer
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  missed     :boolean
#

class ShiftsTask < ActiveRecord::Base
  scope :after_time, ->(time){where("created_at > ?", time)}  
  belongs_to :task
  belongs_to :shift

  # attr_accessor :missed
end
