class AddGlobalToNotices < ActiveRecord::Migration
  def self.up
    add_column :notices, :global, :boolean
  end

  def self.down
    remove_column :notices, :global
  end
end
