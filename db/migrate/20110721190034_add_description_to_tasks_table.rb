class AddDescriptionToTasksTable < ActiveRecord::Migration
  def self.up
    add_column :tasks, :description, :string
  end

  def self.down
    remove_column :tasks, :description
  end
end
