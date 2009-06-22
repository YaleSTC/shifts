class CreatePayformItemSets < ActiveRecord::Migration
  def self.up
    create_table :payform_item_sets do |t|
      t.references :category
      t.date :date
      t.decimal :hours
      t.text :description
      
    end
  end
  
  def self.down
    drop_table :payform_item_sets
  end
end
