class RemoveSinksAndSources < ActiveRecord::Migration
  def self.up
    change_table :notices do |t|
      t.references :noticeable, :polymorphic => true
    end

    change_table :restrictions do |t|
      t.references :restrictable, :polymorphic => true
    end

    # Here we find all location notices, 
    LocationSinksLocationSource.find_all_by_location_sink_type("Notice").each do |lsls|
      if !(notice = Notice.find_by_id lsls.location_sink_id)
        next
      end
      notice.noticeable_id = lsls.location_source_id
      notice.noticeable_type = lsls.location_source_type
      notice.save!
    end

    UserSinksUserSource.find_all_by_user_sink_type("Notice").each do |usus|
      if !(notice = Notice.find_by_id usus.user_sink_id)
        next
      end
      notice.noticeable_id = usus.user_source_id
      notice.noticeable_type = usus.user_source_type
      notice.save!
    end

    LocationSinksLocationSource.find_all_by_location_sink_type("Restriction").each do |lsls|
      if !(restriction = Restriction.find_by_id lsls.location_sink_id)
        next
      end
      restriction.restrictable_id = lsls.location_source_id
      restriction.restrictable_type = lsls.location_source_type
      restriction.save!
    end

    UserSinksUserSource.find_all_by_user_sink_type("Restriction").each do |usus|
      if !(restriction = Restriction.find_by_id usus.user_sink_id)
        next
      end
      restriction.restrictable_id = usus.user_source_id
      restriction.restrictable_type = usus.user_source_type
      restriction.save!
    end


    drop_table :location_sinks_location_sources
    drop_table :user_sinks_user_sources
  end

  def self.down
    create_table :location_sinks_location_sources, :id => false do |t|
      t.references :location_sink, :polymorphic => true
      t.references :location_source, :polymorphic => true
    end

    create_table :user_sinks_user_sources, :id => false do |t|
      t.references :user_sink, :polymorphic => true
      t.references :user_source, :polymorphic => true
    end

    Notice.find_all_by_noticeable_type()

    change_table :notices do |t|
      t.remove_references :noticeable, :polymorphic => true
    end

    change_table :restrictions do |t|
      t.remove_references :restrictable, :polymorphic => true
    end
  end
end

