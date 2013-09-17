class AddStaleShiftStatus < ActiveRecord::Migration
  def self.up
    add_column :shifts, :stale_shifts_unsent, :boolean, :default => true
  end

  def self.down
    remove_column :shifts, :stale_shifts_unsent
  end
end
