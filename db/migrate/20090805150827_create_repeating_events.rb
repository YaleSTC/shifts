class CreateRepeatingEvents < ActiveRecord::Migration
  def self.up
    create_table :repeating_events do |t|
      t.datetime :start_date
      t.datetime :end_date
      t.references :calendar
      t.string :days_of_week
      t.timestamps
    end
  end
  
  def self.down
    drop_table :repeating_events
  end
end
