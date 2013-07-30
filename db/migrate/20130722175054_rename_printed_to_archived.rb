class RenamePrintedToArchived < ActiveRecord::Migration
  def self.up
  	rename_column :payforms, :printed, :archived
  end

  def self.down
  end
end
