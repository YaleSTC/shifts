class AddCategoryIdToLocations < ActiveRecord::Migration
  def self.up
    add_column :locations, :category_id, :integer
  end

  def self.down
    remove_column :locations, :category_id
  end
end
