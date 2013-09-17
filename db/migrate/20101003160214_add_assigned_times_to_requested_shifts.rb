class AddAssignedTimesToRequestedShifts < ActiveRecord::Migration
  def self.up
    add_column :requested_shifts, :assigned_start, :datetime
    add_column :requested_shifts, :assigned_end, :datetime
  end

  def self.down
    remove_column :requested_shifts, :assigned_start
    remove_column :requested_shifts, :assigned_end
  end
end
