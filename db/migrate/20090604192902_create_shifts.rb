class CreateShifts < ActiveRecord::Migration
  def self.up
    create_table :shifts do |t|
      t.datetime :start
      t.datetime :end
      t.boolean :active
      t.references :calendar
      t.references :repeating_event
      t.references :user
      t.references :location
      t.references :department #SPEEDS UP DATABASE QUERIES!
      t.boolean :scheduled, :default => true
      t.boolean :signed_in, :default => false
      t.boolean :power_signed_up, :default => false
      t.timestamps
    end
  end

  def self.down
    drop_table :shifts
  end
end
