class RemoveTemplateIdFromLocations < ActiveRecord::Migration
  def self.up
		remove_column :locations, :template_id
  end

  def self.down
		add_column :locations, :template_id, :integer
  end
end
