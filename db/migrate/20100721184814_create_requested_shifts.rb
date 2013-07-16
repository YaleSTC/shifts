class CreateRequestedShifts < ActiveRecord::Migration
  def self.up
    create_table :requested_shifts do |t|
      t.datetime :preferred_start
      t.datetime :preferred_end
      t.datetime :acceptable_start
      t.datetime :acceptable_end
      t.date :day
			t.references :template
			t.references :user
      t.timestamps
    end
  end

  def self.down
    drop_table :requested_shifts
  end
end
