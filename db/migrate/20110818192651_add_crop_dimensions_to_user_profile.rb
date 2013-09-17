class AddCropDimensionsToUserProfile < ActiveRecord::Migration
  def self.up
    add_column :user_profiles, :crop_x, :integer
    add_column :user_profiles, :crop_y, :integer
    add_column :user_profiles, :crop_h, :integer
    add_column :user_profiles, :crop_w, :integer
  end

  def self.down
    remove_column :user_profiles, :crop_w
    remove_column :user_profiles, :crop_h
    remove_column :user_profiles, :crop_y
    remove_column :user_profiles, :crop_x
  end
end
