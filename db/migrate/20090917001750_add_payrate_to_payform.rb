class AddPayrateToPayform < ActiveRecord::Migration
  def self.up
    add_column :payforms, :payrate, :decimal, :precision => 10, :scale => 2
  end

  def self.down
    remove_column :payforms, :payrate
  end
end
