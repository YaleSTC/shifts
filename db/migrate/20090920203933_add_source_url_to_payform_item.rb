class AddSourceUrlToPayformItem < ActiveRecord::Migration
  def self.up
    add_column :payform_items, :source_url, :string
  end

  def self.down
    remove_column :payform_items, :source_url
  end
end

