class CreateRolesTemplates < ActiveRecord::Migration
  def self.up
    create_table :roles_templates, :id => false do |t|
      t.references :role
      t.references :template

      t.timestamps
    end
  end

  def self.down
    drop_table :roles_templates
  end
end
