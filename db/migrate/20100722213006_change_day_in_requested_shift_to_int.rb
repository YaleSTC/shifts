class ChangeDayInRequestedShiftToInt < ActiveRecord::Migration
  def self.up
		change_column :requested_shifts, :day, :int
  end

  def self.down
		change_column :requested_shifts, :day, :datetime
  end
end
