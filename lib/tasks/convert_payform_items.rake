namespace :db do
  desc "Updates payform_items to use vestal versions plugin structure"

  task update_payform_items: :environment do

    #NOTE: probably make sure payform_items aren't already versioned when you run this script  
    #ALSO,  BACKUP YOUR DATABASE BEFORE RUNNING THIS!!!      
    total = PayformItem.where(parent_id: nil).size
    PayformItem.where(parent_id: nil).each_with_index do |p_i, i|
      #make sure payform_id is assigned to all payforms, based off of their kids
      #this method is made longer because I am only assuming that parent_id exists,
      #  NOT that acts_as_tree is enabled
      puts "#{i} / #{total}"
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
   
    total = PayformItem.where(parent_id: nil).size
    PayformItem.where(parent_id: nil).each_with_index do |p_i, i| 
    
      puts "#{i} / #{total}"
      #p_i.reset_to!(1)
    
      new_p_i = PayformItem.new(p_i.attributes)
    
      #merge in old acts_as_tree records
      kids =  PayformItem.all.select{|p| p.parent_id == p_i.id}

      #set initial version active
      reason = p_i.reason
      new_p_i.active = true
      new_p_i.updated_by = p_i.source
      new_p_i.reason = nil
      new_p_i.save(false)
 
      # IF DELETED
      ############
      if (kids.empty? and !p_i.active)

        #now we delete it
        new_p_i.active = false
        new_p_i.reason = reason
        new_p_i.updated_by = p_i.user.name #may not be accurate if an admin deleted it
        new_p_i.save(false)

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
          new_p_i.active = true
          #if it is a deleted edit
          if (kids.empty? and !kid.active)
            new_p_i.save(false) #set the version that is to be deleted
            #now we delete it
            new_p_i.active = false
            new_p_i.reason = reason
            new_p_i.updated_by = p_i.user.name #may not be accurate if an admin deleted it
          end
          new_p_i.save(false) #update version based off of kid
          old_kids.map{|k| k.destroy } #no longer need this layer of kids (should only have one)
        end
      end

        #destroy the old payform item
      p_i.destroy

    end
  

  end
  
end