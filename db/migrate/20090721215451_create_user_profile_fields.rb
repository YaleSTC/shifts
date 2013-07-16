class CreateUserProfileFields < ActiveRecord::Migration
  def self.up
    create_table :user_profile_fields do |t|
      t.string :name
      t.string :display_type
      t.string :values
      t.boolean :public
      t.boolean :user_editable

      t.references :department
      t.timestamps
    end
  end

  def self.down
    drop_table :user_profile_fields
  end
end

