class CreatePayformItemSets < ActiveRecord::Migration
  def self.up
    create_table :payform_item_sets do |t|
      t.string :name
      t.timestamps
    end
  end
  
  def self.down
    drop_table :payform_item_sets
  end
end
