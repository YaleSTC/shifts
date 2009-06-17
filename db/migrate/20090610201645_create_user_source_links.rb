class CreateUserSourceLinks < ActiveRecord::Migration
  def self.up
    create_table :user_source_links, :id => false do |t|
      t.references :user_sink, :polymorphic => :true
      t.references :user_source, :polymorphic => :true

      t.timestamps
    end
  end

  def self.down
    drop_table :substitute_sources
  end

end
