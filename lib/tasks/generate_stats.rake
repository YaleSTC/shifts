namespace :db do
  
  desc "Updates shifts in the database with shift statistics"
  task :generate_stats => :environment do
    shifts = Shift.unparsed.active.select{|s| s.submitted? or s.missed?}
    shifts.each do |shift|
      shift.update_attribute(:missed, shift.missed?)
      shift.update_attribute(:late, shift.late?)
      shift.update_attribute(:left_early,shift.left_early?)
      shift.update_attribute(:updates_hour, shift.updates_per_hour)
      shift.update_attribute(:parsed, true)
    end
  end
end