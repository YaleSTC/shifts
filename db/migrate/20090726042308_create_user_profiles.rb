class CreateUserProfiles < ActiveRecord::Migration
  def self.up
    create_table :user_profiles do |t|
      t.references :user
      t.references :user_profile_entry
      t.timestamps
    end
  end
  
  def self.down
    drop_table :user_profiles
  end
end
