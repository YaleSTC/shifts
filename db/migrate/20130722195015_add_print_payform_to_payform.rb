class AddPrintPayformToPayform < ActiveRecord::Migration
  def self.up
    add_column :payforms, :print_payform, :boolean
  end

  def self.down
    remove_column :payforms, :print_payform
  end
end
