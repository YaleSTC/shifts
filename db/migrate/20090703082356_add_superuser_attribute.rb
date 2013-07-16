class AddSuperuserAttribute < ActiveRecord::Migration
  def self.up
    add_column :users, :superuser, :boolean, :default => nil
    add_column :users, :supermode, :boolean, :default => true
  end

  def self.down
    remove_column :users, :superuser
    remove_column :users, :supermode
  end
end

