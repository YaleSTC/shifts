class CreateLocationSinksLocationSources < ActiveRecord::Migration
  def self.up
    create_table :location_sinks_location_sources, :id => false do |t|
      t.references :location_sink,   :polymorphic => true
      t.references :location_source, :polymorphic => true
    end
  end

  def self.down
    drop_table :location_sinks_location_sources
  end
end
