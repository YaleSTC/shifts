module TemplatesHelper
  
  def sort(requested_shifts) #if the refactored view ends up working out, this should be moved to the shifts_helpers
    rows = []
    rejected = requested_shifts.sort_by(&:acceptable_start)
    current_row = 0
    while !rejected.empty?
      new_rejected = []
      rows[current_row] = []
      last_shift = nil
      for shift in rejected
        if !last_shift.nil? and shift.overlaps_with(last_shift)
          new_rejected << shift
        else
          rows[current_row] << shift
          last_shift = shift
        end
      end
      rejected = new_rejected
      current_row += 1
    end
    rows
  end
  
end
