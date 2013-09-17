class CreateUserSinksUserSources < ActiveRecord::Migration
  def self.up
    create_table :user_sinks_user_sources, :id => false do |t|
      t.references :user_sink,   :polymorphic => true
      t.references :user_source, :polymorphic => true
    end
  end
  
  def self.down
    drop_table :user_sinks_user_sources
  end
end
