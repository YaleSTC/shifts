class LocationsRequestedShift < ActiveRecord::Base
  belongs_to :requested_shift
  belongs_to :location
end
