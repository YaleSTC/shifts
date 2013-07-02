class RemovePrimaryKeyFromJoinTables < ActiveRecord::Migration
  def self.up
    remove_column :locations_requested_shifts, :id
    remove_column :locations_shift_preferences, :id
  end

  def self.down
    create_column :locations_requested_shifts, :id, :integer
    create_column :locations_shift_preferences, :id, :integer
  end
end
