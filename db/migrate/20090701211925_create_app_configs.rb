class CreateAppConfigs < ActiveRecord::Migration
  def self.up
    create_table :app_configs do |t|
      t.string :footer
      t.string :auth_types
      t.string :ldap_host_address
      t.integer :ldap_port
      t.string :ldap_base
      t.string :ldap_login
      t.string :ldap_first_name
      t.string :ldap_last_name
      t.string :ldap_email
      t.boolean :use_ldap
      t.string :mailer_address
      t.timestamps
    end
  end

  def self.down
    drop_table :app_configs
  end
end
