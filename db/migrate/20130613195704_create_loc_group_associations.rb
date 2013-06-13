class CreateLocGroupAssociations < ActiveRecord::Migration
  def self.up
    create_table :loc_group_associations do |t|
      t.references :loc_group 
      t.references :postable, :polymorphic => true

      t.timestamps
    end
  end

  def self.down
    drop_table :loc_group_associations
  end
end
