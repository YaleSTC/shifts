class CreateDataObjects < ActiveRecord::Migration
  def self.up
    create_table :data_objects do |t|
      t.integer :data_type_id  #probably should use t.references
      t.string  :name
      t.string  :description
      t.timestamps
    end

    # Create the join table
    create_table :data_objects_locations, :id => false do |t|
      t.references :data_object
      t.references :location
    end
  end
  
  def self.down
    drop_table :data_objects
    drop_table :data_objects_locations
  end
end
