class AddLinkToTask < ActiveRecord::Migration
  def self.up
    add_column :tasks, :link, :string
  end

  def self.down
    remove_column :tasks, :link
  end
end
