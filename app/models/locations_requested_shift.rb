# == Schema Information
#
# Table name: locations_requested_shifts
#
#  requested_shift_id :integer
#  location_id        :integer
#  assigned           :boolean          default(FALSE)
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#

class LocationsRequestedShift < ActiveRecord::Base
  belongs_to :requested_shift
  belongs_to :location
end
