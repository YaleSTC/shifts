# == Schema Information
#
# Table name: locations_shift_preferences
#
#  shift_preference_id :integer
#  location_id         :integer
#  kind                :string(255)
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#

class LocationsShiftPreference < ActiveRecord::Base
  belongs_to :shift_preference
  belongs_to :location
end
