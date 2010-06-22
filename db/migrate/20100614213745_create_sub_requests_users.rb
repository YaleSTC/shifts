class CreateSubRequestsUsers < ActiveRecord::Migration
  def self.up
    create_table :sub_requests_users, :id => false do |t|
      t.references :sub_request
      t.references :user
    end
  end

  def self.down
    drop_table :sub_requests_users
  end
end
