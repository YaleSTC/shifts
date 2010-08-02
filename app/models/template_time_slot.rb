class TemplateTimeSlot < ActiveRecord::Base
	belongs_to :template
	belongs_to :location
end
