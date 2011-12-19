class AddActiveStatusToLocGroups < ActiveRecord::Migration
  def self.up
    add_column :loc_groups, :active, :boolean
  end

  def self.down
    remove_column :loc_groups, :active
  end
end
