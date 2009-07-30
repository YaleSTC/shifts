class UserProfile < ActiveRecord::Base

  belongs_to :user
  has_many :user_profile_entries

end

