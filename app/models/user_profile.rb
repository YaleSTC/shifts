# == Schema Information
#
# Table name: user_profiles
#
#  id                 :integer          not null, primary key
#  user_id            :integer
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#  photo_file_name    :string(255)
#  photo_content_type :string(255)
#  photo_file_size    :integer
#  photo_updated_at   :datetime
#  crop_x             :integer
#  crop_y             :integer
#  crop_h             :integer
#  crop_w             :integer
#

class UserProfile < ActiveRecord::Base

  belongs_to :user
  has_many :user_profile_entries

  has_attached_file :photo, #generates profile picture
      styles: { large: "500x500>", medium: "250x250>", small: "150x150>", thumbnail: "100x100#", pico: "22x22#"},
      processors: [:cropper],
      default_url: "/default_attachments/user_profiles/default_:style.jpg",
      url: "/attachments/user_profiles/:id/:style/:normalized_photo_name",
      path: ":rails_root/public/attachments/user_profiles/:id/:style/:normalized_photo_name"
  validates_attachment_size :photo, less_than: 3.megabytes
  validates_attachment_content_type :photo, content_type: ['image/jpeg', 'image/png', 'image/jpg']

  Paperclip.interpolates :normalized_photo_name do |attachment, style|
    attachment.instance.normalized_photo_name
  end

  attr_accessor :crop_x, :crop_y, :crop_w, :crop_h
  after_update :reprocess_photo , if: :cropping?


  def cropping?
    @cropped ||= false
    @should_crop = !crop_x.blank? && !crop_y.blank? && !crop_w.blank? && !crop_h.blank?
    if !@cropped && @should_crop
      @cropped = true
      return true
    else
      return false
    end
  end

  def normalized_photo_name
    "#{self.id}-#{self.photo_file_name.gsub( /[^a-zA-Z0-9_\.]/, '_')}"
  end

  private
  def reprocess_photo
    photo.reprocess!
  end
end
