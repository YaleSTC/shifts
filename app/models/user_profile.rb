class UserProfile < ActiveRecord::Base

  belongs_to :user
  has_many :user_profile_entries
   
  has_attached_file :photo, #generates profile pic. 
      :styles => { :medium => "250x250>", :small => "150x150>", :thumbnail => "100x100>"},
      :default_url => "/assets/user_profiles/adam.jpg",
      :url => "/assets/user_profiles/:id/:style/:basename.extension", 
      :path => ":rails_root/public/assets/user_profiles/:id/:style/:basename.extension"
  
  validates_attachment_size :photo, :less_than => 3.megabytes
  validates_attachment_content_type :photo, :content_type => ['image/jpeg', 'image/png', 'image/jpg']
                
   
end

