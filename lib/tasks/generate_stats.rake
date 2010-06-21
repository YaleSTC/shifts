def generate_stats
  shifts = Shift.parsed
  shifts.each do |shift|
    if shift.missed?
      shift.missed = true
    end
    if shift.late?
      shift.late = true
    end
    if shift.left_early?
      shift.left_early = true
    end
    shift.updates_hour = shift.updates_per_hour
    shift.parsed = true
    shift.save
  end
end

desc "Updates shifts in the database with shift statistics"

task (:generate_stats => :environment) do
  generate_stats
end

task (:clear_stats => :environment) do
  shifts = Shift.parsed
  shifts.each do |shift|
    shift.parsed = false
    shift.save
  end
end