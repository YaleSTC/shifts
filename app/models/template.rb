class Template < ActiveRecord::Base
	has_many :locations
	has_many :requested_shifts
	has_many :shift_preferences
	belongs_to :department
end
