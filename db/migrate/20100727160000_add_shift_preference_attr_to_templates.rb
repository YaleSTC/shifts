class AddShiftPreferenceAttrToTemplates < ActiveRecord::Migration
  def self.up    
    add_column :templates, :max_total_hours, :integer
    add_column :templates, :min_total_hours, :integer
    add_column :templates, :max_continuous_hours, :integer
    add_column :templates, :min_continuous_hours, :integer
    add_column :templates, :max_number_of_shifts, :integer
    add_column :templates, :min_number_of_shifts, :integer
    add_column :templates, :max_hours_per_day, :integer
  end

  def self.down
    remove_column :templates, :max_total_hours
    remove_column :templates, :min_total_hours
    remove_column :templates, :max_continuous_hours
    remove_column :templates, :min_continuous_hours
    remove_column :templates, :max_number_of_shifts
    remove_column :templates, :min_number_of_shifts
    remove_column :templates, :max_hours_per_day
  end
end
