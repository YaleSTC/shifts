class CreateNotices < ActiveRecord::Migration
  def self.up
    create_table :notices do |t|
      t.boolean :is_sticky
      t.string :content
      t.references :author
      t.datetime :start_time
      t.datetime :end_time
      t.references :department
      t.references :remover

      t.timestamps
    end
  end

  def self.down
    drop_table :notices
  end
end

