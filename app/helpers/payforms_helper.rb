module PayformsHelper

  def last_10_dates
    payforms = []
    subtract = (@department.monthly ? 1.month : 1.week)
    date = Date.today
    for i in 0..9
      payforms << Payform.default_period_date(date, @department)
      date -= subtract
    end
    payforms
  end
  
  def start_of_period(date)
    subtract = (@department.monthly ? 1.month : 1.week)
    date - subtract + 1.day
  end

end

