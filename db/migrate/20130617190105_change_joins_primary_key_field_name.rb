class ChangeJoinsPrimaryKeyFieldName < ActiveRecord::Migration
  def self.up
    rename_column :locations_notices, :id, :locations_notices_id
    rename_column :loc_groups_notices, :id, :loc_groups_notices_id
  end

  def self.down
    rename_column :locations_notices, :locations_notices_id, :id
    rename_column :loc_groups_notices, :loc_groups_notices_id, :id
  end
end
