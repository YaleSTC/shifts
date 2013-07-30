namespace :db do
  
  def generate_stats
    shifts = Shift.unparsed.active.select{|s| s.submitted? or s.missed?}
    shifts.each do |shift|
      shift.update_attribute(:missed, shift.missed?)
      shift.update_attribute(:late, shift.late?)
      shift.update_attribute(:left_early,shift.left_early?)
      shift.update_attribute(:updates_hour, shift.updates_per_hour)
      shift.update_attribute(:parsed, true)
    end
  end

  desc "Updates shifts in the database with shift statistics"
  task :update_shift_stats => :environment do
    generate_stats
  end

  task :clear_stats => :environment do
    shifts = Shift.parsed
    shifts.each do |shift|
      shift.parsed = false
      shift.save
    end
  end
end