module PayformsHelper

  def last_10_dates
    payforms = []
    subtract = (@department.department_config.monthly ? 1.month : 1.week)
    date = Date.today
    for i in 0..9
      payforms << Payform.default_period_date(date, @department)
      date -= subtract
    end
    payforms
  end
  
  def selected_hours(payform_item)
    payform_item and payform_item.hours ? payform_item.hours.floor : 0
  end
  
  def selected_min(payform_item)
    payform_item and payform_item.hours ? ((payform_item.hours - payform_item.hours.floor)*60.0 ).round : 0
  end
  
  def start_of_period(date)
    subtract = (@department.department_config.monthly ? 1.month : 1.week)
    date - subtract + 1.day
  end
  
  
  def days_in_period(payform)
    start_date = start_of_period(payform.date)
    end_date = (payform.date < Date.today ? payform.date : Date.today)
    (start_date..end_date).to_a
  end

  def payform_update_button
    if @payform.submitted
      if current_user.is_admin_of?(@payform.department)
        if @payform.approved && !@payform.printed
          link_to "<span><strong>Print</strong></span>", print_payform_path(@payform), :class => "button", :onclick => "this.blur();"
        elsif !@payform.printed
          link_to "<span><strong>Approve and go to next</strong></span>", approve_payform_path(@payform), :class => "button", :onclick => "this.blur();"
        end
      end
    else
      link_to_remote "<span><strong>Submit</strong></span>", :url => submit_payform_path(@payform), :method => :get, :html => {:href => submit_payform_path(@payform), :class => "button", :onclick => "this.blur();"}
    end
  end
  
  def payform_unsubmit_unapprove_button
    if @payform.submitted && !@payform.approved && !@payform.printed
      link_to "<span><strong>Unsubmit</strong></span>", unsubmit_payform_path(@payform), :class => "button", :onclick => "this.blur();"
    elsif @payform.approved && !@payform.printed
      link_to "<span><strong>Unapprove</strong></span>", unapprove_payform_path(@payform), :class => "button", :onclick => "this.blur();"
    end
  end

  def payform_add_button
    unless @payform.approved
      link_to '<span>Add Time</span>', new_payform_payform_item_path(@payform, :height => "400", :width => "600"), 
                     :title => "Add Time", :class => "thickbox button", :onclick => "this.blur();"
    end
  end

  def same_page?(options)
    url_string = CGI.unescapeHTML(url_for(options))
    request = @controller.request
    # We ignore any extra parameters in the request_uri if the 
    # submitted url doesn't have any either.  This lets the function
    # work with things like ?order=asc 
    request_uri = request.request_uri
    
    if url_string =~ /^\w+:\/\//
      url_string == "#{request.protocol}#{request.host_with_port}#{request_uri}"
    else
      url_string == request_uri
    end
  end
end

