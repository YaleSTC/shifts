class CreateShiftPreferences < ActiveRecord::Migration
  def self.up
    create_table :shift_preferences do |t|
      t.integer :max_total_hours
      t.integer :min_total_hours
      t.integer :max_continuous_hours
      t.integer :min_continuous_hours
      t.integer :max_number_of_shifts
      t.integer :min_number_of_shifts
      t.integer :max_hours_per_day
			t.references :template
			t.references :user

      t.timestamps
    end
  end

  def self.down
    drop_table :shift_preferences
  end
end
