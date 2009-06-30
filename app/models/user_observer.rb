class UserObserver < ActiveRecord::Observer
  
  # Automatically create user config for a user
  def after_create(user)
    UserConfig.create!({:user_id => user.id})
  end
  
end
