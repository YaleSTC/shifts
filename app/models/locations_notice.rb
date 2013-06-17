class LocationsNotice < ActiveRecord::Base
  self.primary_key = "locations_notices_id"
  belongs_to :location
  belongs_to :notice
end
