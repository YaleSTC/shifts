class CreateLocations < ActiveRecord::Migration
  def self.up
    create_table :locations do |t|
      t.string      :name
      t.string      :short_name
      t.text        :useful_links
      t.integer     :max_staff
      t.integer     :min_staff
      t.integer     :priority
      t.string      :report_email
      t.boolean     :active
      t.references  :loc_group
			t.references 	:template
      t.timestamps
    end
  end

  def self.down
    drop_table :locations
  end
end
