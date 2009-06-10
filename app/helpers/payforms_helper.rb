module PayformsHelper

  def last_10_payforms
    payforms = []
    date = Date.today
    for i in 0..9
      payforms << Payform.default_period_date(date, @department)
      date -= 1.week
    end
    payforms
  end

end

