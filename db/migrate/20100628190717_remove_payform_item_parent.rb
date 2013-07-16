class RemovePayformItemParent < ActiveRecord::Migration
  def self.up
    #make sure UpdatePayformItemsToVersioned has successfully run or this will destroy edit history
    remove_column :payform_items, :parent_id
  end

  def self.down
    add_column :payform_items, :parent_id, :integer
  end
end
