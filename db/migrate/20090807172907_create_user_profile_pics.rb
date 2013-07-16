class CreateUserProfilePics < ActiveRecord::Migration
  def self.up
    create_table :user_profile_pics do |t|
      t.references :user_profile_entry
      t.timestamps
    end
  end

  def self.down
    drop_table :user_profile_pics
  end
end

