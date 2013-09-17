class AddPublicToTemplates < ActiveRecord::Migration
  def self.up
    add_column :templates, :public, :boolean
  end

  def self.down
    remove_column :templates, :public
  end
end
