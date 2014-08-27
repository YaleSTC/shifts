class CreatePayformItemSets < ActiveRecord::Migration
  def self.up
    create_table :payform_item_sets do |t|
      t.references :category
      t.date :date
      t.decimal :hours, precision: 10, scale: 2
      t.text :description
      t.boolean :active
      t.references :approved_by

    end
  end

  def self.down
    drop_table :payform_item_sets
  end
end
