class CreateDataFields < ActiveRecord::Migration
  def self.up
    create_table :data_fields do |t|
      t.references :data_type    
      t.string     :name
      t.string     :display_type
      t.string     :values
      t.timestamps
    end
  end
  
  def self.down
    drop_table :data_fields
  end
end
