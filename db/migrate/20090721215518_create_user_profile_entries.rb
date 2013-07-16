class CreateUserProfileEntries < ActiveRecord::Migration
  def self.up
    create_table :user_profile_entries do |t|
      t.references :user_profile
      t.references :user_profile_field
      t.string :content
      t.timestamps
    end
  end

  def self.down
    drop_table :user_profile_entries
  end
end

