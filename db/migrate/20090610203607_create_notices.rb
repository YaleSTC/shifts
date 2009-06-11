class CreateNotices < ActiveRecord::Migration
  def self.up
    create_table :notices do |t|
      t.integer :id
      t.boolean :is_sticky
      t.string :content
      t.integer :author_id
      t.datetime :start_time
      t.datetime :end_time
      t.string :for_users
      t.string :for_locations
      t.string :for_location_groups
      t.integer :for_departments
      t.integer :remover_id

      t.timestamps
    end
  end

  def self.down
    drop_table :notices
  end
end
