class CreateLocationAssociations < ActiveRecord::Migration
  def self.up
    create_table :location_associations do |t|
      t.references :location
      t.references :postable, :polymorphic => true

      t.timestamps
    end
  end

  def self.down
    drop_table :location_associations
  end
end
