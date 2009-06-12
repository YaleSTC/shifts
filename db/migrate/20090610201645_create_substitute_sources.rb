class CreateSubstituteSources < ActiveRecord::Migration
  def self.up
    create_table :substitute_sources, :id => false do |t|
      t.references :sub_request
      t.references :user_source, :polymorphic => :true
      
      t.timestamps
    end
  end

  def self.down
    drop_table :substitute_sources
  end

end
