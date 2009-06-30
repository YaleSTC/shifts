class CreatePunchClocks < ActiveRecord::Migration
  def self.up
    create_table :punch_clocks do |t|
      t.string     :description
      t.references :user
      t.timestamps
    end
  end
  
  def self.down
    drop_table :punch_clocks
  end
end
