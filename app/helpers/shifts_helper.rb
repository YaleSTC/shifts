module ShiftsHelper
  def early_late_info(start)
    now = Time.now
    m = distance_of_time_in_words(now - start)
    m += (now > start) ? " ago" : " later"
  end
  
  def load_variables(loc_group)
    #temporary things
    start_hour = " 9:00am"
    end_hour = " 5:00pm"
    
    @day_start = Time.parse(@curr_day + start_hour)
    @day_end = Time.parse(@curr_day + end_hour)

    @can_sign_up = true #loc_group.allow_sign_up? get_user
  end
  
  #use this instead of group_by because we want an array
  def split_to_rows(item_list)
    items_in_row = [[]]
    if item_list
      item_list.each do |sh|
        items_in_row[sh.row] ||= []
        items_in_row[sh.row] << sh
      end
    end
    items_in_row
  end
  
  #needs blocks_per_hour and @user
  def print_cell(type,from,to,shift=nil,content = "", first_time = true)
    span = ((to - from) / 3600 * @blocks_per_hour).floor #convert to integer is impt here
    user_info = ""
    br = ""
    #option for link_to:
    link_name = ""
    url_options = {}
    html_options = {} #to pass id and class name to link_to
    td_title = ""

    extra = "" #other stuff to html,like a hidden div, must not contain table elements

    if span.zero?#return nothing if from and to time are the same
      ''
    else
      if (type=="bar_active")
        if @can_sign_up
          link_name = current_user.is_admin_of?(@department) ? "schedule" : "sign up"
          url_options = {:action => "sign_up",
                :shift => {:start => shift.start, :end => shift.end, :location_id => shift.location_id} }
          html_options = {:class => "sign_up_link"}          
        else
          content = "view only"
          td_title = 'You only have a view access to this cluster, not sign up access.'
        end
      
      elsif (type=="bar_pending")
        content = '-'
        td_title = 'You may not sign up in this slot until a higher priority location is filled.'

      elsif shift
        if type == 'shift_time'
          type.gsub!(/shift/, 'user') if !current_user.is_admin_of?(@department) and shift.user == current_user
          if shift.missed?
            type.gsub!(/time/, 'missed_time')
          elsif (shift.signed_in? ? shift.report.arrived : Time.now) > shift.start + 7 #shift.end_of_grace
            type.gsub!(/time/, 'late_time')
          end
        end

        if span > 3
          user_info = shift.user.name + '<br />' + from.to_s(:twelve_hour) + ' - ' + to.to_s(:twelve_hour)
        else
          user_info = shift.user.login
          td_title = shift.user.name + ',' + from.to_s(:twelve_hour) + ' - ' + to.to_s(:twelve_hour)
        end

        # if first_time && shift.has_sub? && (shift.sub.eligible?(@user) || type=="user_time") &&
        #    (!shift.has_passed? || !shift.sub.new_user)
        #     before_sub = print_cell("shift_time", shift.start, shift.sub.start, shift, "", false)
        #     sub_class_name = shift.sub.has_passed? ? (is_admin? ? "sub_missed_time" : "shift_missed_time") : "sub_time"
        #     sub = print_cell(sub_class_name, shift.sub.start, shift.sub.end, shift, "", false)
        #     after_sub = print_cell("shift_time", shift.sub.end, shift.end, shift, "", false)
        # 
        #     s = before_sub + sub + after_sub
        #     return s

        #els
        if type=="sub_time"
          br = '<br />'
          if current_user.is_admin_of?(@department) or shift.user==current_user
            con_name = current_user.is_admin_of?(@department) ? 'shift_admin' : 'shift'
            link_name = "cancel sub"
            url_options = {:controller => con_name, :action => "sign_in", :id => shift}
            html_options = {:class => "sign_in_link"} unless current_user.is_admin_of?(@department)
          else
            link_name = "accept sub"
            url_options = {:controller => "shift", :action => "sub_accept", :id => shift.sub}
            type = "accept_sub"
            html_options = {:onclick => make_popup(:title => 'Accept this sub?')}
          end
          #this prepares sub reason as a popup
          sub = shift.sub
          html_options = {:id => "sub_link_#{sub.id}", :class => "popup_link" }
          extra = render_to_string(:partial => 'shift/sub_reason', :locals => {:sub => sub})

        elsif shift.signed_in? #display shift report
          # link to view report on a new page
          br = '<br />'
          if (shift.user==@user && !shift.submitted?)
            link_name = "return"
            view_action = "view"
            html_options = {}
          else
            link_name = "view"
            view_action = "view_float"
            html_options = {:rel => "floatbox#{shift.location_id}", :rev => "width:500px height:500px" }
          end

          #TODO: should this just always go to the report show action?
          # if current_user.is_admin_of?(@department)
            url_options = shift_report_path(shift.report)
          #   html_options = {}
          # else
          #   url_options = {:controller => "report", :action => "show", :id => shift}
          # end

          #this prepares view report as a popup, only yesterday onwards
          if shift.start >= Date.today
            report = shift.report
            html_options.merge!(:id => "report_link_#{report.id}", :class => "popup_link")
            extra = render(:partial => 'reports/report_popup', :locals => {:report => report})
          end

        elsif type=="user_time" and not shift.has_passed? #if shift belongs to user and can be signed up
          br = '<br />'
          url_options = shift_report_path(shift)
          html_options = {:class => "sign_in_link"}
          link_name = "options"

        elsif type=="user_late_time"
          br = '<br />'
          url_options = {:controller => "shift", :action => "sign_in", :id => shift}
          html_options = {:class=> "late_sign_in_link"}
          link_name = "options"

        elsif current_user.is_admin_of?(@department) and not shift.has_passed? and not shift.signed_in?
          br = '<br />'
          url_options = edit_shift_path(shift)
          link_name = "edit"
          
        end

      end

      content += user_info + br + link_to(link_name, url_options, html_options)
      "<td title='#{td_title}' class='#{type}' colspan=#{span}>#{content}</td>" + extra
    end
  end
end
