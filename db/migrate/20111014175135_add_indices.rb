class AddIndices < ActiveRecord::Migration
  def self.up
    add_index(:shifts, :user_id)
  end

  def self.down
  end
end
