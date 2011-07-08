namespace :db do
  def make_empty_profile_entries
    users = User.all
    
    users.each do |user|
      all_fields = UserProfileField.all
      current_field_ids = user.user_profile.user_profile_entries.collect{|upe| upe.user_profile_field_id}
      missing_fields = all_fields.delete_if{|upf| current_field_ids.include?(upf.id)}
      puts "#{user.name}, entries to add: #{missing_fields.size}"
      missing_fields.each do |field|
        new_upe = UserProfileEntry.create(:user_profile_id => user.user_profile.id, :user_profile_field_id => field.id)
        new_upe.save
      end
    end
  end
  
  desc "Populates profiles with empty instances of all profile fields"
  task (:repair_profiles => :environment) do
    make_empty_profile_entries
  end
end