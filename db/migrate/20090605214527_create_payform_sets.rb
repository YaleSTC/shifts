class CreatePayformSets < ActiveRecord::Migration
  def self.up
    create_table :payform_sets do |t|
      t.references :department
      t.timestamps
    end
  end
  
  def self.down
    drop_table :payform_sets
  end
end
