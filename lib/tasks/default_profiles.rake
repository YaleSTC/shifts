namespace :db do
  def make_empty_profile_entries_for_default(department_name)
    department = Department.where(name: department_name).first
    users = User.all.select{|u| u.departments.include?(department)}
    all_field_ids = UserProfileField.all.select{|upf| upf.department_id == department.id}.map{|upf| upf.id}
    users.each do |user|
      all_entries=user.user_profile.user_profile_entries
      
      current_field_ids = user.user_profile.user_profile_entries.collect{|upe| upe.user_profile_field_id}
      missing_field_ids = all_field_ids.select{|upf_id| !current_field_ids.include?(upf_id)}
      all_entries.each do |entry|
        if !entry.destroy
          puts "#{user.name} entry not deleted"
        end
      end
      puts "#{user.name}, entries deleted"
      missing_field_ids.each do |field_id|
        new_upe = UserProfileEntry.create(user_profile_id: user.user_profile.id, user_profile_field_id: field_id)
        new_upe.save
      end
      current_field_ids.each do |field_id|
        new_upe = UserProfileEntry.create(user_profile_id: user.user_profile.id, user_profile_field_id: field_id)
        new_upe.save
      end
      puts "#{user.name}, empty entries added: #{missing_field_ids.size+current_field_ids.size}"
    end
  rescue
    puts "#{department_name} is not a valid department name. Please enter a valid name."
  end

  desc "Rewrite profiles with empty instances of all department profile fields"
  task :default_profiles, [:department_name] => :environment do |t, args|
    department_name = args[:department_name]
    make_empty_profile_entries_for_default(department_name)
  end
end