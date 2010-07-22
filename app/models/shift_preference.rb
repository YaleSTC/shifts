class ShiftPreference < ActiveRecord::Base
	belongs_to :user
	has_and_belongs_to_many :locations
	belongs_to :template
end
