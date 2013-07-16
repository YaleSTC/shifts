class ChangeNoticesContentToText < ActiveRecord::Migration
  def self.up
    change_column :notices, :content, :text
  end

  def self.down
        change_column :notices, :content, :string
  end
end
