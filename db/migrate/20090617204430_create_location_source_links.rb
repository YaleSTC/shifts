class CreateLocationSourceLinks < ActiveRecord::Migration
  def self.up
    create_table :location_source_links, :id => false do |t|
      t.references :location_sink, :polymorphic => :true
      t.references :location_source, :polymorphic => :true

      t.timestamps
    end
  end

  def self.down
    drop_table :location_source_links
  end

end
