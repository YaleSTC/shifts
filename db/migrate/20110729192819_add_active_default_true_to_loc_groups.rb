class AddActiveDefaultTrueToLocGroups < ActiveRecord::Migration
  def self.up
    add_column :loc_groups, :active, :boolean, default: true
  end

  def self.down
    remove_column :loc_groups, :active
  end
end
