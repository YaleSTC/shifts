class ShiftPreference < ActiveRecord::Base
	belongs_to :user
	has_many :locations_shift_preferences
	has_many :locations, :through => :locations_shift_preferences
	belongs_to :template
end
