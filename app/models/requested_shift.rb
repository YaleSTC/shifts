class RequestedShift < ActiveRecord::Base
	has_and_belongs_to_many :locations
	belongs_to :user
	belongs_to :template
end
