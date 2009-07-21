class UserProfileField < ActiveRecord::Base

  def after_create(user_profile_field)
    @department.users.each do |user|
      UserProfileEntry.create!(:user_id => user.id,
                               :user_profile_field_id => user_profile_field.id)
    end
  end
end

