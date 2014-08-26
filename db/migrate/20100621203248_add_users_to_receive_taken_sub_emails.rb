class AddUsersToReceiveTakenSubEmails < ActiveRecord::Migration
  def self.up
    add_column :user_configs, :taken_sub_email, :boolean, default: true
  end

  def self.down
    remove_column :user_configs, :taken_sub_email
  end
end
