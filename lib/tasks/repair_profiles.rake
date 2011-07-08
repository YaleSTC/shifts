namespace :db do
  
  def make_empty_profile_entries
    users = User.all
    all_fields = UserProfileField.all
    
    users.each do |user|
      current_field_ids = user.user_profiles.user_profile_entries.collect{|upe| upe.user_profile_field_id}
      missing_fields = all_fields.delete_if{|upf| current_field_ids.include?(upf.id)}
      missing_fields.each do |field|
        UserProfileEntry.create!(:user_profile_id => user.user_profile.id, :user_profile_field_id => field.id)
      end
    end
  end
  
  desc "Populates profiles with empty instances of all profile fields"
  task (:repair_profiles => :environment) do
    make_empty_profile_entries
  end
end