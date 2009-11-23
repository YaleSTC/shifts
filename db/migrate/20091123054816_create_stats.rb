class CreateStats < ActiveRecord::Migration
  def self.up
    create_table :stats do |t|
      t.datetime :start
      t.datetime :stop
      t.string :user_ids
      t.string :location_ids
      t.string :location_group_ids
      t.string :department_ids
      t.string :view_by, :default => 'all'
      t.string :group_by, :default => 'user'
      t.timestamps
    end
  end
  
  def self.down
    drop_table :stats
  end
end
