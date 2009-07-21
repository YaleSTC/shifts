class UserProfileEntry < ActiveRecord::Base

  has_one :user_profile_field
  has_one :user

  validates_presence_of :user_id

end

