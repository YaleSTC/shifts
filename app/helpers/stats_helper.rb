module StatsHelper
  def split_shifts_or_slots(loc, shifts_or_slots)

    day_shifts = shifts_or_slots.group_by {|sh| sh.start.beginning_of_day}
    day_arr = [0,0,0,0,0,0,0]
    occur   = [0,0,0,0,0,0,0]
    dur     = [0,0,0,0,0,0,0]

    day_shifts.sort.each do |d, shs|
      day = d.wday #value between 0 and 6
      row_shifts = loc.flatten_one_row(shs)
      day_arr[day] += Stat.duration(row_shifts)
      occur[day] += 1
    end

    for day in 0..6
       dur[day] = occur[day].zero? ? 0 : (day_arr[day]/occur[day])
    end

    return day_arr, dur, occur
  end
end
