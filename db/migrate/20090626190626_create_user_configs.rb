class CreateUserConfigs < ActiveRecord::Migration
  def self.up
    create_table :user_configs do |t|
      t.references  :user
      t.integer     :default_dept
      t.string      :view_loc_groups
      t.string      :view_week
      t.string      :watched_data_objects
      t.timestamps
    end
  end

  def self.down
    drop_table :user_configs
  end
end

