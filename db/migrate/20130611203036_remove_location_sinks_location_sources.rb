class RemoveLocationSinksLocationSources < ActiveRecord::Migration
  def self.up
    change_table :notices do |t|
      t.references :noticeable, :polymorphic => true
    end

    change_table :restrictions do |t|
      t.references :restrictable, :polymorphic => true
    end

    drop_table :location_sinks_location_sources
    drop_table :user_sinks_user_sources
  end

  def self.down
    change_table :notices do |t|
      t.remove_references :noticeable, :polymorphic => true
    end

    change_table :restrictions do |t|
      t.remove_references :restrictions, :polymorphic => true
    end

    create_table :location_sinks_location_sources, :id => false do |t|
      t.references :location_sink, :polymorphic => true
      t.references :location_source, :polymorphic => true
    end

    create_table :user_sinks_user_sources, :id => false do |t|
      t.references :user_sink, :polymorphic => true
      t.references :user_source, :polymorphic => true
    end
  end
end

