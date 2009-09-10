class CreateRepeatingEvents < ActiveRecord::Migration
  def self.up
    create_table :repeating_events do |t|
      t.datetime :start_date
      t.datetime :end_date
      t.datetime :start_time
      t.datetime :end_time
      t.references :calendar
      t.string :days_of_week
      t.references :user
      t.string :loc_ids
      t.boolean :is_set_of_timeslots
      t.timestamps
    end
  end

  def self.down
    drop_table :repeating_events
  end
end
