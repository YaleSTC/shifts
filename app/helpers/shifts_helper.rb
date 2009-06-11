module ShiftsHelper
  def early_late_info(start)
    now = Time.now
    m = distance_of_time_in_words(now - start)
    m += (now > start) ? " ago" : " later"
  end
  
  def load_variables(loc_group)
    #TODO: maybe clean this up?
    @day_start = Time.parse("0:00", @curr_day) + @dept_start_hour*3600
    @day_end = Time.parse("0:00", @curr_day)  + @dept_end_hour*3600

    @can_sign_up = true #loc_group.allow_sign_up? get_user
  end
  
  # TODO: this shit
  def populate_loc(loc, shifts)
    #loc.label_row_for(shifts) #assigns row number for each shift (shift.row)
    #loc.count_people_for(shifts, min_block)#count number of people working concurrently for each time block
    #loc.apply_time_slot_in(@day_start, @day_end, min_block)#check if time is valid or not
    #loc.create_bar(@day_start, @day_end, min_block)
    @bar_id = loc.short_name + @curr_day.to_s
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
  def print_cell(type,from,to,shift=nil,content = "", render_pass = -1, overflow = false)
    if from == to #return nothing if from and to time are the same
      ''
    else
      span = ((to - from) / 3600 * @blocks_per_hour).floor #convert to integer is impt here
      # display the shift time correctly, even if the shift overflows
      if overflow == "left"
        from = shift.start
      elsif overflow == "right"
        to = shift.end
      end
      user_info = ""
      br = ""
      #option for link_to:
      link_name = ""
      url_options = {}
      html_options = {} #to pass id and class name to link_to
      td_title = ""

      extra = "" #other stuff to html,like a hidden div, must not contain table elements

      if (type=="bar_active")
        if @can_sign_up #TODO: implement this
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
          type.gsub!(/shift/, 'user') if shift.user == current_user and !current_user.is_admin_of?(@department)
          if shift.missed?
            type.gsub!(/time/, 'missed_time')
          elsif (shift.signed_in? ? shift.report.arrived : Time.now) > shift.start + @grace_period #TODO: get grace period for department/location
            type.gsub!(/time/, 'late_time')
          end
        end

        if span > 3
          user_info = shift.user.name + '<br />' + from.to_s(:twelve_hour) + ' - ' + to.to_s(:twelve_hour)
        else
          user_info = shift.user.login
          td_title = shift.user.name + ', ' + from.to_s(:twelve_hour) + ' - ' + to.to_s(:twelve_hour)
        end
        
        # if first_time && shift.has_sub? && (shift.sub.eligible?(@user) || type=="user_time") &&
        #    (!shift.has_passed? || !shift.sub.new_user)
        # TODO: explain in comments what 'render_pass' is. basically, it's how we deal with
        #       recursion when handling shifts with sub requests
        if render_pass == -1 && shift.has_sub? && !shift.has_passed?
            sorted_sub_requests = shift.sub_requests.sort_by(&:start)
            
            s=""
            
            current_time = shift.start
            
            sorted_sub_requests.each_with_index do |sub, i|
              before_sub_block = print_cell("shift_time", current_time, sub.start, shift, "", i)
              #sub_class_name = shift.sub.has_passed? ? (is_admin? ? "sub_missed_time" : "shift_missed_time") : "sub_time"
              sub_class_name = shift.has_passed? ? (is_admin? ? "sub_missed_time" : "shift_missed_time") : "sub_time"
              sub_block = print_cell(sub_class_name, sub.start, sub.end, shift, "", i, overflow && shift.sub.end >= @day_end)

              s += before_sub_block + sub_block
              current_time = sub.end
            end
            
            after_sub_block = print_cell("shift_time", sorted_sub_requests.last.end, shift.end, shift, "", 0,  overflow && shift.end >= @day_end)
            s += after_sub_block
            
            return s
            
        elsif type=="sub_time"
          sub = shift.sub_requests.sort_by(&:start)[render_pass]
          br = '<br />'
          if current_user.is_admin_of?(@department) or shift.user==current_user
            con_name = current_user.is_admin_of?(@department) ? 'shift_admin' : 'shift'
            link_name = "cancel sub"
            url_options = sub
            html_options = {:class => "sign_in_link"}# unless current_user.is_admin_of?(@department)
          else
            link_name = "accept sub"
            url_options = {:controller => "shifts", :action => "sub_accept", :id => shift.sub}
            type = "accept_sub"
            html_options = {:onclick => make_popup(:title => 'Accept this sub?')}
          end
          #this prepares sub reason as a popup
          html_options = {:id => "sub_link_#{sub.id}", :class => "popup_link" }
          extra = render(:partial => 'sub_reason', :locals => {:sub => sub})

        elsif shift.signed_in? #display shift report
          # link to view report on a new page
          br = '<br />'
          if (shift.user==current_user && !shift.submitted?)
            link_name = "return"
            view_action = shift_report_path(shift)
            html_options = {}
          else
            link_name = "view"
            view_action = "view_float"
            html_options = {:rel => "floatbox#{shift.location_id}", :rev => "width:500px height:500px" }
          end

          #TODO: should this just always go to the report show action?
          # if current_user.is_admin_of?(@department)
            url_options = shift_report_path(shift)
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
          url_options = shift
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

      type += " overflow_right" if overflow == "right"
      type += " overflow_left" if overflow == "left"

      content += user_info + br + link_to(link_name, url_options, html_options)
      "<td title='#{td_title}' class='#{type}' colspan=#{span}>#{content}</td>" + extra
    end
  end
  
  def show_bar_links(name)
    javascript_tag("$('%s').down('.%s').show()" % [@curr_day, name])
  end
  
  #TODO: look at this and show_bars and make sure they're efficient
  def hide_bars(name)
    f = ""
    @bar_ids[@curr_day].each { |id| f << "Effect.Fade('#{id}', { duration: 0.3 });"}
    unless f.empty?
      f << "$(this).up().hide();"
      f << "$(this).up().next().show();"
      link_to_function(name, f)
    end
  end

  def show_bars(name)
    f = ""
    @bar_ids[@curr_day].each { |id| f << "Effect.Appear('#{id}', { duration: 0.3 });"}
    unless f.empty?
      f << "$(this).up().hide();"
      f << "$(this).up().previous().show();"
      link_to_function(name, f)
    end
  end
  
  def sign_up_div_id
    "quick_sign_up_%s" % @curr_day
  end

  def sign_in_div_id
    "quick_sign_in_%s" % @curr_day
  end
end
