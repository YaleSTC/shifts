class AddDescriptionToLocationTable < ActiveRecord::Migration
  def self.up
    add_column :locations, :description, :string
  end

  def self.down
    remove_column :locations, :description
  end
end
