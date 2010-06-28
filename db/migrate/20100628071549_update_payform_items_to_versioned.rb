class UpdatePayformItemsToVersioned < ActiveRecord::Migration
  
  def self.up
    say_with_time "Converting payform_items to versioned items" do
      #find "version one" items
      PayformItem.find(:all,:conditions => {:parent_id => nil}).each do |p_i|
        
        #NOTE: probably make sure payform_items aren't already versioned when you run this script
        
        #ALSO,  BACKUP YOUR DATABASE BEFORE RUNNING THIS!!!
        
        while p_i.payform.nil?
          kid =  PayformItem.all.select{|p| p.parent_id == p_i.id}.first
          if kid.payform.nil?
            p_i = kid
          else
            payform = kid.payform
            p_i.payform = payform
            p_i.skip_version do
              p_i.save(false)
            end
            while !p_i.parent_id.nil?
              p_i = PayformItem.find(p_i.parent_id)
              p_i.payform = payform
              p_i.skip_version do
                p_i.save(false)
              end
            end
          end
        end
        
        #p_i.reset_to!(1)
        
        #merge in old acts_as_tree records
        kids =  PayformItem.all.select{|p| p.parent_id == p_i.id}
        # IF DELETED
        ############
        if (kids.empty? and !p_i.active)
          reason = p_i.reason
          p_i.skip_version do
            p_i.active = true
            p_i.updated_by = p_i.source
            p_i.reason = nil
            p_i.save!(false) #set the initial version
          end
          p_i.append_version do
            p_i.active = false
            p_i.reason = reason
            p_i.updated_by = p_i.source
            p_i.save!(false) #now we delete this item with versioning
          end
        # ELSE RECURSE THROUGH KIDS
        ###########################
        else 
          reason = p_i.reason
          p_i.skip_version do
            p_i.updated_by = p_i.source
            p_i.reason = nil
            p_i.active = true
            p_i.save!(false) #set the initial version
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
              p_i.save!(false) #update version based off of kid
              kid.destroy #no longer need kid
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
