class ShiftsTask < ActiveRecord::Base
  scope :after_time, ->(time){where("created_at > ?", time)}  
  belongs_to :task
  belongs_to :shift

  # attr_accessor :missed
end