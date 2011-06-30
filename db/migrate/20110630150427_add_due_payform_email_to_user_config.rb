class AddDuePayformEmailToUserConfig < ActiveRecord::Migration
  def self.up
    add_column :user_configs, :due_payform_email, :boolean, :default=>true
  end

  def self.down
    remove_column :user_configs, :due_payform_email
  end
end
