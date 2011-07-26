class DroppUserProfilePicTable < ActiveRecord::Migration
  def self.up
    drop_table :user_profile_pics
  end

  def self.down
    create_table :user_profile_pics do |t|
      t.references :user_profile_entry
      t.timestamps
    end
  end
end
