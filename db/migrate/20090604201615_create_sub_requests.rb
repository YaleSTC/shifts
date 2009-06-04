class CreateSubRequests < ActiveRecord::Migration
  def self.up
    create_table :sub_requests do |t|
      t.references :user
      t.references :shift
      t.datetime :bribe_start
      t.datetime :bribe_end
      t.datetime :start
      t.datetime :end
      t.datetime :end
      t.references :new_shift #TODO: does this really need to go into the database?
      t.references :new_user  #TODO: does this really need to go into the database?
      t.text :reason
      t.string :target_ids    #TODO: would it be better to create a join table for this? or not store this in the database at all?
                              #(do offers only apply to emails, or do they give exlusive access to the sub to the users in this list?)
      t.timestamps
    end
  end

  def self.down
    drop_table :sub_requests
  end
end

