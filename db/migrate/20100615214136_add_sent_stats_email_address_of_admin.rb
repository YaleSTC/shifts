class AddSentStatsEmailAddressOfAdmin < ActiveRecord::Migration
  def self.up
    add_column :department_configs, :stats_mailer_address, :string
  end

  def self.down
    remove_column :department_configs, :stats_mailer_address
  end
end
