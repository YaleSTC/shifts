class RequestedShift < ActiveRecord::Base
	has_and_belongs_to_many :locations
	belongs_to :user
	belongs_to :template

	WEEK_DAY_SELECT = [
    ["Monday", 0],
    ["Tuesday", 1],
    ["Wednesday", 2],
    ["Thursday", 3],
    ["Friday", 4],
    ["Saturday", 5],
    ["Sunday", 6]
  ]
end
