class CreatePunchClockSets < ActiveRecord::Migration
  def self.up
    create_table :punch_clock_sets do |t|
      t.string :description
      t.references :department

      t.timestamps
    end
  end

  def self.down
    drop_table :punch_clock_sets
  end
end
