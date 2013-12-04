class UpdateVestalVersions < ActiveRecord::Migration
  def self.up
    add_column    :versions, :reverted_from, :integer
    rename_column :versions, :changes, :modifications
  end

  def self.down
    remove_column :versions, :reverted_from
    rename_column :versions, :modifications, :changes
  end
end
