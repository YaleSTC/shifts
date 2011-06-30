namespace :db do
  
  def populate_missed_tasks(start_date, end_date)
    #for past day
    #find shifts 
    #find tasks considered missed
    #create hash of missed shifts tasks... already in missed tasks?
    tasks = Task.after_now.delete_if{|t| t.kind == "Weekly" && t.day_in_week != (start_date).strftime("%a")}
    
    tasks.each do |task|
      shifts_missed_task_hash = task.missed_between(start_date, end_date) #supposed to be run at 1 am according to schedule
      hash_keys = shifts_missed_task_hash.keys
      hash_keys.each do |key|
        shifts_missed_task_array = shifts_missed_task_hash[key]
        shifts_missed_task_array.each do |shift|
          @shifts_task = ShiftsTask.new(:task_id => task.id, :shift_id => shift.id, :created_at => key, :missed => true )
      		@shifts_task.save
    		end
      end
    end
  end
  
  # def clear_missed_tasks
  #   shifts_tasks = ShiftsTask.find_all_by_missed(true)
  #   shifts_tasks.each do |st|
  #     st.
  #   end
  #   
  # end
  
  desc "Populates shifts tasks join table with entries calculated to be missed"
  task (:populate_missed_tasks => :environment) do
    populate_missed_tasks(Date.today - 1, Date.today)
  end
  
  # desc "Clears missed shifts tasks and repopulates full list (very computationally intensive!)"
  # task (:reset_missed_tasks => :environment) do
  # end

end