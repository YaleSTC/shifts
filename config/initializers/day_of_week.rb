WEEK_DAYS = ["Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"]
HOURS = Array.new(12){|i| i + 1}
AM_PM = [["AM",0],["PM",1]]

class Fixnum
  
  def day_of_week
    WEEK_DAYS[self]
  end
  
  def min_to_am_pm
    (Date.new + self.minutes).to_s(:am_pm)
  end
end

class Date
  def sunday
    self - wday
  end
end

class Date
  def self.from_select_date(hash)
    return Date.today if hash.nil?
    Date.civil(hash["year"].to_i, hash["month"].to_i, hash["day"].to_i)
  end
end

class Time
  def sunday_of_week
    (self - self.wday.days).midnight
  end
end

