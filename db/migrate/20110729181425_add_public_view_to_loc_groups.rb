class AddPublicViewToLocGroups < ActiveRecord::Migration
  def self.up
    add_column :loc_groups, :public, :boolean, default: true
  end

  def self.down
    remove_column :loc_groups, :public
  end
end
