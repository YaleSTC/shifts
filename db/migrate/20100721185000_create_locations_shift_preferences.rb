class CreateLocationsShiftPreferences < ActiveRecord::Migration
  def self.up
    create_table :locations_shift_preferences do |t|
      t.references :shift_preference
      t.references :location
			t.string :kind

      t.timestamps
    end
  end

  def self.down
    drop_table :locations_shift_preferences
  end
end