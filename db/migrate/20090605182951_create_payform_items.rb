class CreatePayformItems < ActiveRecord::Migration
  def self.up
    create_table :payform_items do |t|
      t.references :category
      t.references :user
      t.references :payform_item #if this is an edit, the parent is the more recent version

      t.boolean :active, :default => true
      t.decimal :hours


      t.text :description
      t.text :reason #reason for deletion or edit
      t.string :source #where it came from (shifts, rt, admin: adam, mass_job, etc)

      t.datetime "submitted"
      t.datetime "approved"
      t.datetime "printed"
      t.timestamps
    end
  end

  def self.down
    drop_table :payform_items
  end
end

