class CreateCategories < ActiveRecord::Migration
  def self.up
    create_table :categories do |t|
      t.boolean :active, :default => true
      t.boolean :built_in, :default => false
      t.string :name
      t.references :department
      t.timestamps
    end
  end
  
  def self.down
    drop_table :categories
  end
end
