module ShiftsHelper
  
  #WILL BE CHANGED TO SHIFTS:
  def shift_style(shift)
    left = ((shift.start - (shift.start.at_beginning_of_day + @dept_start_hour.hours))/3600.0)/@hours_per_day*100
    width = (shift.duration/3600.0) / @hours_per_day * 100
    if left < 0 
      width -= left
      left = 0 
    elsif left < 0 
      left=0
      width=100/@hours_per_day
    end
    if left + width > 100
      width -= (left+width)-100
    end
    "width: #{width}%; left: #{left}%;"
  end

  def load_schedule_variables()
    #@bar_ids ||= {}
    @blocks_per_hour ||= @department.department_config.blocks_per_hour
    @blocks_per_day ||= @department.department_config.blocks_per_day
    @block_length ||= @department.department_config.block_length
    @display_unscheduled_shifts ||= @department.department_config.unscheduled_shifts
    @loc_groups ||= current_user.user_config.view_loc_groups.split(', ').map{|lg|LocGroup.find(lg)}
  end
  
  def load_day_variables(day)
    @current_day = day
    #@bar_ids[day] = []
    @shifts_outside_display = []
    
    #prepare all the shift data. ALL OF IT. SO MUCH INFORMATION.
    populate_all_locs(@loc_groups, @block_length)
  end

  def load_loc_group_variables(loc_group)
    #@loc_group = loc_group
  end

  # TODO: this shit
  def populate_all_locs(loc_groups, min_block)
    #TODO: drastic optimization. we might try something like this:
    #  -grab data from the database in large chunks
    #  -use group_by to break it up into subgroups
    #  -process the subgroups

    #creates a bunch of arrays holding all the data we'll need to write for each location today
    @scheduled_shifts = {}
    @unscheduled_shifts = {}
    @bar = {}
    @people_count = {}
    loc_groups.each do |loc_group|
      # different location groups can have different start/end times...maybe bring this down
      # further, to the individual location level?
        # TODO: modify this once we implement department group settings
      @day_start = Time.parse("0:00", @current_day) + @dept_start_hour*3600
      @day_end = Time.parse("0:00", @current_day)  + @dept_end_hour*3600
      @prioritized_location = {}
      loc_group.locations.each do |loc|
        if loc.active?
          @open_at = apply_time_slot_in(loc, @day_start, @day_end, min_block)

          shifts = Shift.find(:all, :conditions => {:location_id => loc}).select{|shift| ((shift.start < @day_end) and shift.end and (shift.end > @day_start))}.sort_by(&:start)
          shifts = shifts.group_by(&:scheduled)
          @scheduled_shifts[loc.object_id] = [shifts[true]]
          @unscheduled_shifts[loc.object_id] = [shifts[false]]

          people_count = loc.count_people_for(shifts[true], min_block)#count number of people working concurrently for each time block
          @bar[loc.object_id] = create_bar(@day_start, @day_end, people_count, min_block, loc) unless @day_end < Time.now
          #@bar_ids[@current_day] << loc.short_name + @current_day.to_s
          @people_count[loc.object_id] = people_count
        end
      end
    end
  end





  def apply_time_slot_in(location, day_start, day_end, min_block)
    #get open timeslot on the day: date is Date object and when converted to time, its time is at midnight
    slots = TimeSlot.find(:all, :conditions => ['location_id = ? AND end >= ? AND start <= ?', location, day_start, day_end])

    open_at = {}
    open_at.default = false

    slots.each do |ts|
      t = ts.start
      while (t<ts.end)
        open_at[t.to_s(:am_pm)] = true
        t += min_block
      end
    end
    open_at
  end

  def create_bar(day_start, day_end, people_count, min_block, location)
    bar = []
    block_start = day_start
    #don't return a bar unless it has at least one time that can be signed up for
    should_return = false;

    while (block_start < day_end)
      t = block_start
      free_status = nil

      begin

        if not @open_at[t.to_s(:am_pm)] : current_status = 'bar_inactive'
        elsif (people_count[t.to_s(:am_pm)] >= location.max_staff) : current_status = 'bar_full'
        elsif (t<Time.now) : current_status = 'bar_passed'
        elsif @prioritized_location[t] and @prioritized_location[t].priority > location.priority
          # if another location has higher priority
          current_status = 'bar_pending'
          should_return = true
        else
          if (people_count[t.to_s(:am_pm)] < location.min_staff)
            # if this location has not reached minimum staff yet, give it priority
            @prioritized_location[t] = location
          end
          current_status = 'bar_active'
          should_return = true
        end

        free_status ||= current_status
      end while (current_status == free_status) and (t <= day_end) and (t += min_block)

      t = day_end if t > day_end
      bar << [block_start, t, free_status]
      block_start = t
    end
    should_return ? bar : nil
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
      if (type=="free_time")
        #then location is passed instead of shift
        location = shift
        shift = nil
      end
      span = ((to - from) / 3600 * @blocks_per_hour).round #convert to integer is impt here
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
        if current_user.can_signup?(@loc_group)
          link_name = current_user.is_admin_of?(@loc_group) ? "schedule" : "sign up"
          url_options = {:controller => 'shifts', :action => 'new',
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
          elsif (shift.signed_in? ? shift.report.arrived : Time.now) > shift.start + @department.department_config.grace_period*60 #seconds
            type.gsub!(/time/, 'late_time')
          end
        end

        if span > 3
          if shift.scheduled?
            user_info = shift.user.name + '<br />' + from.to_s(:twelve_hour) + ' - ' + to.to_s(:twelve_hour)
          else
            user_info = shift.user.name
          end
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
              if sub.user_is_eligible?(current_user)
                before_sub_block = print_cell("shift_time", current_time, sub.start, shift, "", i)
                sub_class_name = shift.has_passed? ? (is_admin? ? "sub_missed_time" : "shift_missed_time") : "sub_time"
                sub_block = print_cell(sub_class_name, sub.start, sub.end, shift, "", i, overflow && shift.sub.end >= @day_end)

                s += before_sub_block + sub_block
                current_time = sub.end
              else
                #skip this sub
              end
            end

            after_sub_block = print_cell("shift_time", current_time, shift.end, shift, "", 0,  overflow && shift.end >= @day_end)
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
            url_options = get_take_info_sub_request_path(sub)
            type = "accept_sub"
            html_options = {:onclick => make_popup(:title => 'Accept this sub?')}
          end
          #this prepares sub reason as a popup
          html_options = {:id => "sub_link_#{sub.id}", :class => "popup_link" }
          extra = render(:partial => 'sub_reason', :locals => {:sub => sub})
          td_title = "Reason: "+sub.reason

        elsif shift.signed_in? #display shift report
          # link to view report on a new page
          br = '<br />'
          if (shift.user==current_user && !shift.submitted?)
            link_name = "return"
            view_action = shift_report_path(shift)
            html_options = {}
          else
            link_name = "view"
            #view_action = shift_report_path(shift)#"view_float"
            #TODO: render without layout
            url_options = {:controller => 'reports', :action => 'popup', :id => shift.report, :TB_iframe => true, :width => 450}
            html_options = {:class => 'thickbox', :rel => 'shift_reports'}
          end

          #TODO: should this just always go to the report show action?
          # if current_user.is_admin_of?(@department)
          #   url_options = shift_report_path(shift)
          #   html_options = {}
          # else
          #   url_options = {:controller => "report", :action => "show", :id => shift}
          # end

          #this prepares view report as a popup, only yesterday onwards
          # if shift.start >= Date.today
          #   report = shift.report
          #   html_options.merge!(:id => "report_link_#{report.id}", :class => "popup_link", :rel => "lightbox")
          #   #extra = render(:partial => 'reports/report_popup', :locals => {:report => report})
          # end

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
          html_options = {:class => 'clickable_edit', :id => "edit||"+shift.id.to_s}
          link_name = "edit"

        end

        if (!shift.scheduled?)
          br = " "
          type += " unscheduled"
          link_name = "(#{link_name})"
        end

      end

      type += " overflow_right" if overflow == "right"
      type += " overflow_left" if overflow == "left"

      content += user_info + br + link_to(link_name, url_options, html_options)

      #TODO: make this a department preference
      clickable_signup_preference = false;
      clickable_signup = clickable_signup_preference
      if clickable_signup and type=="free_time" and location #bar_active"#
        #print a bunch of individual cells, so we can click and add shifts
        loc = location #shift.location_id
        result = ""
        time = from
        span.times do
          signup_url = new_shift_path+"?shift%5Bstart%5D="+time.to_s
          #signup_url += "&shift%5Blocation_id%5D="+location.id.to_s
          #pass variables via id?
          id = loc.id.to_s+"||"+time.to_s
          time += @block_length
          temp_type = (time == to or time >= @day_end) ? "end_of_segment" : (time.strftime("%M") == "00" ? "end_of_hour" : nil)
          #link = nil #"<a class='linkbox' rel='signup'>#{content}</a>" #"<a class='linkbox' rel='lightbox' href='#{signup_url}'>#{content}</a>"
          result += "<td title='#{td_title}' id='#{id}' class='#{type} clickable_signup #{temp_type}' colspan='1'>&#8200;</td>" + extra
        end
        result
      else
        "<td title='#{td_title}' class='#{type}' colspan=\"#{span}\">#{content}</td>" + extra
      end
    end
  end
  
  # #TODO: does this work in jQuery? OR get rid of it
  # def show_bar_links(name)
  #   javascript_tag("$('%s').down('.%s').show()" % [@current_day, name])
  # end
  # 
  # #TODO: make this work in jQuery, OR get rid of it
  # def hide_bars(name)
  #   f = ""
  #   @bar_ids[@current_day].each { |id| f << "Effect.Fade('#{id}', { duration: 0.3 });"}
  #   unless f.empty?
  #     f << "$(this).up().hide();"
  #     f << "$(this).up().next().show();"
  #     link_to_function(name, f)
  #   end
  # end
  # 
  # #TODO: make this work in jQuery, OR get rid of it
  # def show_bars(name)
  #   f = ""
  #   @bar_ids[@current_day].each { |id| f << "Effect.Appear('#{id}', { duration: 0.3 });"}
  #   unless f.empty?
  #     f << "$(this).up().hide();"
  #     f << "$(this).up().previous().show();"
  #     link_to_function(name, f)
  #   end
  # end

  def sign_up_div_id
    "quick_sign_up_%s" % @current_day
  end

  def sign_in_div_id
    "quick_sign_in_%s" % @current_day
  end
end

