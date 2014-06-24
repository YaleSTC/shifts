class CreateRestrictions < ActiveRecord::Migration
  def self.up
    create_table :restrictions do |t|
      t.datetime :starts
      t.datetime :expires
      t.integer :max_subs
      t.decimal :max_hours, precision: 10, scale: 2
      t.timestamps
    end
  end

  def self.down
    drop_table :restrictions
  end
end
