# encoding: UTF-8

module ApplicationHelper
  def link_toggle(id, name, speed = "slow")
    # "<a href='#' onclick=\"Element.toggle('%s'); return false;\">%s</a>" % [id, name]
    link_to_function name, "$('##{id}').slideToggle('#{speed}')"
    # link_to_function name, "Effect.toggle('#{id}', 'appear', { duration: 0.3 });"
  end

	def link_to_post_a_link
		if current_user.is_loc_group_admin?(current_department) || current_user.is_admin_of?(current_department)
    	link_to_unless_current('Post a new link', 
        new_link_path(type: "Link"), 
        data: { toggle: 'modal', target: '#modal', remote: new_link_path(layout: "false") },
        class: "btn btn-default", id: "post_link" )
		end
  end

	def link_to_post_a_sticky
		link_to_unless_current('Post a new sticky',
      new_sticky_path, title: "Post a new sticky",
      data: { toggle: 'modal', target: '#modal', remote: new_sticky_path(layout: "false") },
      id: "post_link", class: 'btn btn-default')
  end

	def link_to_post_an_announcement
		if current_user.is_loc_group_admin?(current_department) || current_user.is_admin_of?(current_department)
			link_to_unless_current('Post a new announcement',
        new_announcement_path, 
        data: { toggle: 'modal', target: '#modal', remote: new_announcement_path(layout: "false")}, 
        id: "announcement_link", class: 'btn btn-default')
		end
	end

  def early_late_info(start)
    now = Time.now
    m = distance_of_time_in_words(now - start)
    m += (now > start) ? " ago" : " from now"
  end

  def user_has_active_shift?
    current_user.current_shift
  end

  def users_to_autocomplete_json(users)
    return [] if !users
    result = Array.new
    users.each do |u|
      result << {id: "User||#{u.id}", name: "#{u.full_name_with_nick} (#{u.login})"}
    end
    result.to_json.html_safe
  end


  def select_integer (object, column, start, stop, interval = 1, default = nil)
    output = "<select id=\"#{object}_#{column}\" name=\"#{object}[#{column}]\">"
    for i in start..stop
      if i%interval == 0
        output << "\n<option value=\"#{i}\""
        output << " selected=\"selected\"" if i == default
        output << ">#{i}"
      end
    end
    (output + "</select>").html_safe
  end


  def time_format
    '%I:%M%p'
  end

  def date_format
    '%B %d, %Y'
  end

  #requires a div with id "AJAX_status" to be included in the page
  def ajax_alert(page, content, delay_length = 2.5)
    rand = "rand"+rand(10000).to_s #unique id for element
    page.insert_html :top, "AJAX_status", "<div id='#{rand}' class='AJAX_alert'>#{content}</div>"
    page[rand].visual_effect :slide_down
    page[rand].visual_effect :highlight
    page.delay(delay_length) do
      page[rand].visual_effect :slide_up
    end
  end

  def persistent_ajax_alert(page, content)
    rand = "rand"+rand(10000).to_s #unique id for element
    page.insert_html :top, "AJAX_status", "<div id='#{rand}' class='AJAX_alert'><a href='#' style='float:right;' onclick='$(this).parent().remove(); return false;'>[x]</a><br>#{content}</div>"
    page[rand].visual_effect :slide_down
    page[rand].visual_effect :highlight
  end

  def calculate_default_times_repeating_events
    if params[:date]
      #From the parameters, including the entire current week
      @default_start_date = Date.parse(params[:date])
    else
      #The current week
      @default_start_date = Time.now.to_date
    end
    @repeating_event.start_time ||= @default_start_date.to_time + current_department.department_config.schedule_start.minutes
    @repeating_event.end_time ||= @default_start_date.to_time + current_department.department_config.schedule_end.minutes
    @range_start_time = Time.now.to_date + current_department.department_config.schedule_start.minutes
    @range_end_time = Time.now.to_date + current_department.department_config.schedule_end.minutes
    if params[:location_id] #this param comes from the timeline on creation of a new repeating_event
      @repeating_event.location_ids = [] << params[:location_id]
    end
  end

  def navbar_highlight(controller_name)
    navbar_hash = Hash[ "dashboard" => ["dashboard"],
                        "departments" => ["departments", "app_configs", "department_configs", "locations", "loc_groups",
										  "calendars", "application", "templates", "calendar_feeds", "time_slots"],
                        "users" => ["users", "roles", "user_profiles", "superusers", "user_profile_fields"],
                        "shifts" => ["shifts", "links", "notices", "data_objects", "stats", "announcements", "data_entries",
									 "data_fields", "data_types", "repeating_events", "report_items", "stickies", "tasks", "reports"],
                        "payforms" => ["payforms", "payform_items", "punch_clocks", "punch_clock_sets", "payform_item_sets", "categories"]]
    navbar_hash.select{|key, value| value.include?(controller_name) }.flatten.first
  end

  def normalize_str(string)
    string.downcase.gsub( /[^a-zA-Z0-9_\.]/, '_')
  end

end
