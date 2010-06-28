class UpdatePayformItemsToVersioned < ActiveRecord::Migration
  def self.up
    say_with_time "Converting payform_items to versioned items" do
      #find "version one" items
      PayformItem.find(:all,:conditions => {:parent_id => nil}).each do |p_i|
        
        #NOTE: probably make sure payform_items aren't already versioned when you run this script
        
        #ALSO,  BACKUP YOUR DATABASE BEFORE RUNNING THIS!!!
        
        p_i.reset_to!(0)
        
        #merge in old acts_as_tree records
        kids =  PayformItem.all.select{|p| p.parent_id == p_i.id}
        # IF DELETED
        ############
        if (kids.empty? and !p_i.active)
          p_i.skip_version do
            p_i.active = true
            reason = p_i.reason
            p_i.updated_by = p_i.source
            p_i.reason = nil
            p_i.save! #activate versioned on this item, initially active
          end
          p_i.append_version do
            p_i.active = false
            p_i.reason = reason
            p_i.updated_by = p_i.source
            p_i.save! #now we delete this item with versioning
          end
        # ELSE RECURSE THROUGH KIDS
        ###########################
        else 
          p_i.skip_version do
            p_i.updated_by = p_i.source
            reason = p_i.reason
            p_i.reason = nil
            p_i.active = true
            p_i.save!
          end

          while !kids.empty?
            p_i.append_version do
              kid = kids.first
              new_reason = reason
              reason = kid.reason
              p_i.attributes = kid.attributes
              p_i.reason = new_reason
              p_i.updated_by = kid.source
              kids =  PayformItem.all.select{|p| p.parent_id == kid.id}
              unless (kids.empty?)
                p_i.active = true
              end
              p_i.save!
              kid.destroy
            end
          end
        end
      end
    end
  end

  def self.down
    raise ActiveRecord::IrreversibleMigration
    #THIS IS IRREVERSABLE (BE WARNED)
    #(unless you want to write this method.)
    #(it is theoretically possible...)
  end
  
end
