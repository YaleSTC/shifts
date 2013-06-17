class LocationsNotice < ActiveRecord::Base
  belongs_to :location
  belongs_to :notice
end
