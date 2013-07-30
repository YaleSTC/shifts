class AddPrintPayformToUsers < ActiveRecord::Migration
  def self.up
    add_column :users, :print_payform, :boolean
  end

  def self.down
    remove_column :users, :print_payform
  end
end
