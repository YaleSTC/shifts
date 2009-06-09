class CreateSubRequests < ActiveRecord::Migration
  def self.up
    create_table :sub_requests do |t|
      t.datetime :start
      t.datetime :end
      t.string :potential_takers
      t.string :reason
      t.references :shift

      t.timestamps
    end
  end

  def self.down
    drop_table :sub_requests
  end
end

