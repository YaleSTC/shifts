namespace :db do
  def make_empty_profile_entries(department_name)
    department = Department.find_by_name(department_name)
    users = User.all.select{|u| u.departments.include?(department)}
    all_field_ids = UserProfileField.all.select{|upf| upf.department_id == department.id}.map{|upf| upf.id}
    users.each do |user|
      current_field_ids = user.user_profile.user_profile_entries.collect{|upe| upe.user_profile_field_id}
      missing_field_ids = all_field_ids.select{|upf_id| !current_field_ids.include?(upf_id)}
      missing_field_ids.each do |field_id|
        new_upe = UserProfileEntry.create(:user_profile_id => user.user_profile.id, :user_profile_field_id => field_id)
        new_upe.save
      end
      puts "#{user.name}, entries added: #{missing_field_ids.size}"
    end
  rescue
    puts "#{department_name} is not a valid department name. Please enter a valid name."
  end

  desc "Populates profiles with empty instances of all department profile fields"
  task :repair_profiles, [:department_name] => :environment do |t, args|
    department_name = args[:department_name]
    make_empty_profile_entries(department_name)
  end
end