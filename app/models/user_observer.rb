class UserObserver < ActiveRecord::Observer

  # Automatically create user config for a user
  def after_create(user)

    UserConfig.create!({:user_id => user.id,
                        :view_loc_groups => "",
                        :view_week => "",
                        :default_dept => user.departments.first.id
                        })
# does user.departments.first suffice here? for some reason @department isn't calling anything
    if !user.departments.first.user_profile_fields.empty?
      user.departments.first.user_profile_fields.each do |field|
        UserProfileEntry.create!(:user_id => user.id,
                                 :user_profile_field_id => field.id)
      end
    end
  end

end

