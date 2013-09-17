class AddStatAttrToShifts < ActiveRecord::Migration
  def self.up
    add_column :shifts, :missed, :boolean, :default => false
    add_column :shifts, :late, :boolean, :default => false
    add_column :shifts, :left_early, :boolean, :default => false
    add_column :shifts, :parsed, :boolean, :default => false
    add_column :shifts, :updates_hour, :decimal, :precision => 5, :scale => 2, :default => 0
  end

  def self.down
    remove_column :shifts, :updates_hour
    remove_column :shifts, :parsed
    remove_column :shifts, :left_early
    remove_column :shifts, :late
    remove_column :shifts, :missed
  end
end
