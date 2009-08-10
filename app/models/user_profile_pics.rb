class UserProfilePics < ActiveRecord::Base

  belongs_to :user_profile_entry

  has_attached_file :photo,
  :styles => {
    :thumb => "100x100",
    :standard => "300x30>",
    :large => "700x700>"
  }

  validates_attachment_presence :photo
  validates_attachment_content_type :photo,
  :content_type => ['image/jpeg', 'image/pjpeg',
                                   'image/jpg', 'image/png']


end

