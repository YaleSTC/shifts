class AddMissedToShiftsTask < ActiveRecord::Migration
  def self.up
    add_column :shifts_tasks, :missed, :boolean
  end

  def self.down
    remove_column :shifts_tasks, :missed
  end
end
