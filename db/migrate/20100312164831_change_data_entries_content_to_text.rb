class ChangeDataEntriesContentToText < ActiveRecord::Migration
  def self.up
    change_column :data_entries, :content, :text
  end

  def self.down
    change_column :data_entries, :content, :string
  end
end
