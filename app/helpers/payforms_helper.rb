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

  def time_format
    '%A, %B %d, %Y at %I:%M%p'
  end
  
  def date_format
    '%B %d, %Y'
  end

  def payform_update_button
    if @payform.submitted
      if @current_user.is_admin_of?(@payform.department)
        if @payform.approved && !@payform.printed
          link_to "<span><strong>Print Payform</strong></span>", print_payform_path(@payform), :class => "button", :onclick => "this.blur();", :method => :put
        elsif !@payform.printed
          link_to "<span><strong>Approve Payform</strong></span>", approve_payform_path(@payform), :class => "button", :onclick => "this.blur();", :method => :put
        end
      end
    else
      link_to "<span><strong>Submit Payform</strong></span>", submit_payform_path(@payform), :class => "button", :onclick => "this.blur();", :method => :put
    end
  end
  
  def payform_add_button
    unless @payform.approved
      link_to "<span>New Payform Item</span>", new_payform_payform_item_path(@payform), :class => "button", :onclick => "this.blur();"
    end
  end

end

