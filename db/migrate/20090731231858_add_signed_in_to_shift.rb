class AddSignedInToShift < ActiveRecord::Migration
  def self.up
    add_column :shifts, :signed_in, :boolean, :default => :false
  end

  def self.down
    remove_column :shifts, :signed_in
  end
end
