class CreateLocationsRequestedShifts < ActiveRecord::Migration
  def self.up
    create_table :locations_requested_shifts do |t|
      t.references :requested_shift
      t.references :location
			t.boolean :assigned, default: false

      t.timestamps
    end
  end

  def self.down
		drop_table :locations_requested_shifts
  end
end
