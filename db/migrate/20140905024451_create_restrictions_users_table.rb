class CreateRestrictionsUsersTable < ActiveRecord::Migration
  def up
  	create_table :restrictions_users, id: false do |t|
  		t.belongs_to :restriction
  		t.belongs_to :user
  	end
  	create_table :locations_restrictions, id: false do |t|
  		t.belongs_to :restriction
  		t.belongs_to :location
  	end
  	create_table :loc_groups_restrictions, id: false do |t|
  		t.belongs_to :restriction
  		t.belongs_to :loc_group
  	end
  end

  def down
    drop_table :restrictions_users
    drop_table :locations_restrictions
    drop_table :loc_groups_restrictions
  end
end
