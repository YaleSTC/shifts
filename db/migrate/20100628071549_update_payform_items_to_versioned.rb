class UpdatePayformItemsToVersioned < ActiveRecord::Migration
  
  def self.up
    say_with_time "Adding proper payform_id to all payform_items" do
      
      #NOTE: probably make sure payform_items aren't already versioned when you run this script  
      #ALSO,  BACKUP YOUR DATABASE BEFORE RUNNING THIS!!!      
      
      PayformItem.find(:all,:conditions => {:parent_id => nil}).each do |p_i|
        #make sure payform_id is assigned to all payforms, based off of their kids
        #this method is made longer because I am only assuming that parent_id exists,
        #  NOT that acts_as_tree is enabled
        while p_i.payform.nil?
          kid =  PayformItem.all.select{|p| p.parent_id == p_i.id}.first
          if kid.payform.nil?
            p_i = kid
          else
            payform = kid.payform
            p_i.payform = payform
            p_i.save(false)
            while !p_i.parent_id.nil?
              p_i = PayformItem.find(p_i.parent_id)
              p_i.payform = payform
              p_i.save(false)
            end
          end
        end
        
      end
    end
    say_with_time "Regenerating payform_items as versioned items" do
      PayformItem.find(:all,:conditions => {:parent_id => nil}).each do |p_i| 

        #p_i.reset_to!(1)
        
        new_p_i = PayformItem.new(p_i.attributes)
        
        #merge in old acts_as_tree records
        kids =  PayformItem.all.select{|p| p.parent_id == p_i.id}

        #set initial version active
        reason = p_i.reason
        new_p_i.active = true
        new_p_i.updated_by = p_i.source
        new_p_i.reason = nil
        new_p_i.save!(false)
     
        # IF DELETED
        ############
        if (kids.empty? and !p_i.active)

          #now we delete it
          new_p_i.active = false
          new_p_i.reason = reason
          new_p_i.updated_by = p_i.user.name #may not be accurate if an admin deleted it
          new_p_i.save!(false)

        # ELSE RECURSE THROUGH KIDS
        ###########################
        else 
          while (!kids.empty?)
            kid = kids.first
            new_reason = reason
            reason = kid.reason              
            new_p_i.attributes = kid.attributes
            new_p_i.reason = new_reason
            new_p_i.updated_by = p_i.user.name #may not be accurate if an admin edited it
            old_kids = kids
            kids =  PayformItem.all.select{|p| p.parent_id == kid.id}
            unless (kids.empty?)
              new_p_i.active = true
            end
            new_p_i.save!(false) #update version based off of kid
            old_kids.map{|k| k.destroy } #no longer need this layer of kids (should only have one)
          end
        end

        #destroy the old payform item
        p_i.destroy

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
