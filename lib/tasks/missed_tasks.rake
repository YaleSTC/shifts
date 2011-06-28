namespace :db do
  
  def missed_tasks
    #for past hour? (or past 2 hours to past 1 hour)
    #find shifts 
    #find tasks considered missed
    #create hash of missed shifts tasks... already in missed tasks?
    tasks = Task.after_now.delete_if{|t| t.kind == "Weekly" && t.day_in_week != @shift.start.strftime("%a")}
    shifts = []
    shifts_task_hash = {}
    
    tasks.each do |task|
      task
    end
  end

end