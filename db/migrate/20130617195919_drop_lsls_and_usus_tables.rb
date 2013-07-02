class DropLslsAndUsusTables < ActiveRecord::Migration
  def self.up
    drop_table :location_sinks_location_sources
    drop_table :user_sinks_user_sources
  end

  def self.down
    create_table :location_sinks_location_sources do |t|
      t.references location_sinks, :polymorphic => true
      t.references location_sources, :polymorphic => true
    end

    create_table :user_sinks_user_sources do |t|
      t.references user_sinks, :polymorphic => true
      t.references user_sources, :polymorphic => true
    end
  end
end
