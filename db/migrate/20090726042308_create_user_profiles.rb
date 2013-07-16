class CreateUserProfiles < ActiveRecord::Migration
  def self.up
    create_table :user_profiles do |t|
      t.references :user
      t.timestamps
    end
  end

  def self.down
    drop_table :user_profiles
  end
end

