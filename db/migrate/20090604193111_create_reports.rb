class CreateReports < ActiveRecord::Migration
  def self.up
    create_table :reports do |t|
      t.references :shift
      t.datetime :start
      t.datetime :end
      t.string :login_ip
      t.string :logout_ip
      t.timestamps
    end
  end
  
  def self.down
    drop_table :reports
  end
end
