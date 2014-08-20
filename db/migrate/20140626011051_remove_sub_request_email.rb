class RemoveSubRequestEmail < ActiveRecord::Migration
  def up
    remove_column :loc_groups, :sub_request_email
  end

  def down
    add_column :loc_groups, :sub_request_email
  end
end
