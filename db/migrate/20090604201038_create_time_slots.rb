class CreateTimeSlots < ActiveRecord::Migration
  def self.up
    create_table :time_slots do |t|
      t.references :location
      t.references :calendar
      t.references :repeating_event
      t.datetime :start
      t.datetime :end
      t.boolean :active
      t.timestamps
    end
  end

  def self.down
    drop_table :time_slots
  end
end
