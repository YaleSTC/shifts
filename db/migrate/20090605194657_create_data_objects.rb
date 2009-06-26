class CreateDataObjects < ActiveRecord::Migration
  def self.up
    create_table :data_objects do |t|
      t.integer :data_type_id  #probably should use t.references
      t.string  :name
      t.string  :description
      t.timestamps
    end

    create_table :data_objects_locations, :id => false do |t|
      t.integer :data_object_id
      t.integer :location_id
    end
  end
  
  def self.down
    drop_table :data_objects
  end
end
