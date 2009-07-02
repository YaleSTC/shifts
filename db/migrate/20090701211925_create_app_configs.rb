class CreateAppConfigs < ActiveRecord::Migration
  def self.up
    create_table :app_configs do |t|
      t.string :footer
      t.string :auth_types
      t.timestamps
    end
  end
  
  def self.down
    drop_table :app_configs
  end
end
