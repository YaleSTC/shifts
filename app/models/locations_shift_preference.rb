class LocationsShiftPreference < ActiveRecord::Base
  belongs_to :shift_preference
  belongs_to :location
end
