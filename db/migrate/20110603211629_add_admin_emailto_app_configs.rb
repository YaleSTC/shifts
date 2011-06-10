class AddAdminEmailtoAppConfigs < ActiveRecord::Migration
  def self.up
    add_column :app_configs, :admin_email, :string
  end

  def self.down
    remove_column :app_configs, :admin_email
  end
end
