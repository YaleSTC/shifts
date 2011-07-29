class AddActiveStatustoLocGroupsDefaultTrue < ActiveRecord::Migration
   def self.up
      remove_column :loc_groups, :active
    end

    def self.down
      add_column :loc_groups, :active, :boolean
    end
  end
