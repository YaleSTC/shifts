class UserObserver < ActiveRecord::Observer

  # Automatically create user config for a user
  # default to viewing all location groups
  def after_create(user)
    UserConfig.create!({:user_id => user.id,
                        :view_loc_groups => (user.departments.collect{|d| d.loc_groups}.flatten.collect{|l| l.id} * ", "),
                        :view_week => "",
                        :watched_data_objects => "",
                        :default_dept => user.departments.first.id
                        })
  end

end

