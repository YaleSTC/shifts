class CreatePayformItems < ActiveRecord::Migration
  def self.up
    create_table :payform_items do |t|
      t.boolean :deleted
      t.decimal :hours
      t.references :user
      t.string :source
      t.text :escription
      t.references :category
      t.timestamps
    end
  end
  
  def self.down
    drop_table :payform_items
  end
end
