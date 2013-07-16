module PunchClocksHelper

  def punch_clock_class(clock)
    if clock.paused?
      return "paused"
    else
      return "running"
    end
  end

end
