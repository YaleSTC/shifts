class CreateReportItems < ActiveRecord::Migration
  def self.up
    create_table :report_items do |t|
      t.references :report
      t.datetime :time
      t.text :content
      t.string :ip_address
      t.timestamps
    end
  end

  def self.down
    drop_table :report_items
  end
end
