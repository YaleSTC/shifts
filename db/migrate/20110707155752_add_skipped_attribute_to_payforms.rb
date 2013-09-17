class AddSkippedAttributeToPayforms < ActiveRecord::Migration
  def self.up
    add_column :payforms, :skipped, :datetime
  end

  def self.down
    remove_column :payforms, :skipped
  end
end
