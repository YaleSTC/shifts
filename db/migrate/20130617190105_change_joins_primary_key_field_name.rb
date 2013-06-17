class ChangeJoinsPrimaryKeyFieldName < ActiveRecord::Migration
  # Necessary because some of the habtm methods would return the ids of the join
  # tables rather than the id of the objects that they returned
  def self.up
    rename_column :locations_notices, :id, :locations_notices_id
    rename_column :loc_groups_notices, :id, :loc_groups_notices_id
  end

  def self.down
    rename_column :locations_notices, :locations_notices_id, :id
    rename_column :loc_groups_notices, :loc_groups_notices_id, :id
  end
end
