class AddActiveToDataFields < ActiveRecord::Migration
  def self.up
    add_column :data_fields, :active, :boolean, default: true
  end

  def self.down
    remove_column :data_fields, :active
  end
end
