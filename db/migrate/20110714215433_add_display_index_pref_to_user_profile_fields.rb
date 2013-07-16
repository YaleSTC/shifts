class AddDisplayIndexPrefToUserProfileFields < ActiveRecord::Migration
  def self.up
    add_column :user_profile_fields, :index_display, :boolean, :default => true
  end

  def self.down
    remove_column :user_profile_fields, :index_display
  end
end
