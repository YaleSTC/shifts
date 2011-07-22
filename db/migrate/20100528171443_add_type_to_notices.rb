class AddTypeToNotices < ActiveRecord::Migration
  def self.up
		add_column :notices, :url, :string
		add_column :notices, :type, :string
  end

  def self.down
		remove_column :notices, :type
		remove_column :notices, :url 
  end
end
