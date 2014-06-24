class CreateNotices < ActiveRecord::Migration
  def self.up
    create_table :notices do |t|
      t.boolean :sticky, default: false
      t.boolean :useful_link, default: false
      t.boolean :announcement, default: false
      t.boolean :indefinite
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

