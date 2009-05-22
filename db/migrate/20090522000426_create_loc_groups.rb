class CreateLocGroups < ActiveRecord::Migration
  def self.up
    create_table :loc_groups do |t|
      t.string :name
      t.integer :department_id
      t.integer :view_perm_id
      t.integer :signup_perm_id
      t.integer :admin_perm_id
      t.timestamps
    end
  end
  
  def self.down
    drop_table :loc_groups
  end
end
