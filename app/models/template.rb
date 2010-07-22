class Template < ActiveRecord::Base
	has_many :locations
	has_many :requested_shifts
	belongs_to :department
end
