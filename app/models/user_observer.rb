class UserObserver < ActiveRecord::Observer

  # Automatically create user config for a user
  # default to viewing all location groups
  def after_create(user)

    UserConfig.create!({:user_id => user.id,
                        :view_loc_groups => (user.departments.collect{|d| d.loc_groups}.flatten.collect{|l| l.id} * ", "),
                        :view_week => "",
                        :default_dept => user.departments.first.id
                        })

    profile = UserProfile.new({:user_id => user.id})
      UserProfileField.find(:all, :conditions => {:department_id => user.departments.first.id}).each do |field|
        UserProfileEntry.create!({:user_profile_id => profile.id,
                                  :user_profile_field_id => field.id})
      end
    profile.save!
  end

end

