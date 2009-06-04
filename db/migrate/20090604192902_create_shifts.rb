class CreateShifts < ActiveRecord::Migration
  def self.up
    create_table :shifts do |t|
      t.datetime :start
      t.datetime :end
      t.references :user
      t.references :location
      t.timestamps
    end
  end

  def self.down
    drop_table :shifts
  end
end

