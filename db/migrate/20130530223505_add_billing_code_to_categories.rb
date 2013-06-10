class AddBillingCodeToCategories < ActiveRecord::Migration
  def self.up
    add_column :categories, :billing_code, :string
  end

  def self.down
    remove_column :categories, :billing_code
  end
end
