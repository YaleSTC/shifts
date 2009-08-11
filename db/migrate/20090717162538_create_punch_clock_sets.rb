class CreatePunchClockSets < ActiveRecord::Migration
  def self.up
    create_table :punch_clock_sets do |t|
      t.string :description
      t.references :department

      t.timestamps
    end

    add_column :punch_clocks, :punch_clock_set_id, :integer
  end

  def self.down
    drop_table :punch_clock_sets
    
    remove_column :punch_clocks, :punch_clock_set_id
  end
end
