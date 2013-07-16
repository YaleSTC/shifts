class CreateSubRequests < ActiveRecord::Migration
  def self.up
    create_table :sub_requests do |t|
      t.datetime :start
      t.datetime :end
      t.datetime :mandatory_start
      t.datetime :mandatory_end
      t.string :reason
      t.references :shift
      t.references :user #Speeds up database queries!


      t.timestamps
    end
  end

  def self.down
    drop_table :sub_requests
  end
end
