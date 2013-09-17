class CreateLocGroups < ActiveRecord::Migration
  def self.up
    create_table :loc_groups do |t|
      t.string :name
      t.string :sub_request_email
      t.references :department
      t.references :view_perm
      t.references :signup_perm
      t.references :admin_perm
      t.timestamps
    end
  end

  def self.down
    drop_table :loc_groups
  end
end

