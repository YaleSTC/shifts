class ChangeSubRequestReasonToText < ActiveRecord::Migration
  def self.up
    change_column :sub_requests, :reason, :text
  end

  def self.down
    change_column :sub_requests, :reason, :string
  end
end

