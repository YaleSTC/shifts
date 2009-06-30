class UserConfig < ActiveRecord::Base
  belongs_to :user
  
  validates_presence_of   :user_id
  validates_uniqueness_of :user_id
  
  VIEW_WEEK_OPTIONS = [
    # Displayed               stored in db
    ["Whole pay period",      "whole_period"],
    ["Remainder of period",   "remainder"],
    ["Just the current day",  "current_day"]
  ]
end
