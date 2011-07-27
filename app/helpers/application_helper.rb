# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper

  def link_toggle(id, name, speed = "slow")
    # "<a href='#' onclick=\"Element.toggle('%s'); return false;\">%s</a>" % [id, name]
    link_to_function name, "$('##{id}').slideToggle('#{speed}')"
    # link_to_function name, "Effect.toggle('#{id}', 'appear', { duration: 0.3 });"
  end

	def link_to_post_a_link
		if current_user.is_loc_group_admin?(current_department) || current_user.is_admin_of?(current_department)
    	link_to_unless_current('Post a new link', new_link_path(:height => 225, :width => 515, :type => "Link"), :title => "Post a new link", :class => "thickbox", :id => "post_link" )
		end
  end

	def link_to_post_a_sticky()
		link_to_unless_current('Post a new sticky', new_sticky_path(:height => 200, :width => 515, :type => "Sticky"), :title => "Post a new sticky", :class => "thickbox", :id => "post_link" )
  end

	def link_to_post_an_announcement
		if current_user.is_loc_group_admin?(current_department) || current_user.is_admin_of?(current_department)
			link_to_unless_current('Post a new announcement', new_announcement_path(:height => 345, :width => 515), :title => "Post a new announcement", :class => "thickbox", :id => "announcement_link")
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

  def tokenized_users_autocomplete(object, field, options = {})
    #set defaults
    options.reverse_merge!({
      :id => "list_of_logins",
      :hint_text => "Type a name, NetID, role or department",
      :style => "vertical", #default to vertical style -- seems more appropriate
      :classes => ["User","Role","Department"],
      :include_headers => true
    })


    if (options[:style] == "facebook")
      style = 'tokenList: "token-input-list-facebook",
              token: "token-input-token-facebook",
              tokenDelete: "token-input-delete-token-facebook",
              selectedToken: "token-input-selected-token-facebook",
              highlightedToken: "token-input-highlighted-token-facebook",
              dropdown: "token-input-dropdown-facebook",
              dropdownItem: "token-input-dropdown-item-facebook",
              dropdownItem2: "token-input-dropdown-item2-facebook",
              selectedDropdownItem: "token-input-selected-dropdown-item-facebook",
              inputToken: "token-input-input-token-facebook"'
      css_file = 'tokeninput-facebook'
    else
      style = ''
      css_file = 'token-input'
    end

    json_string = ""
    unless object.nil? or field.nil?
      object.send(field).each do |user_source|
        json_string += "{name: '#{user_source.name}', id: '#{user_source.class}||#{user_source.id}'},\n"
      end
    end

    #Tell the app to put javascript info at top and bottom of pages (Unobtrusive Javascript - style)
    content_for :javascript,
      '$(document).ready(function() {
        $("#'+options[:id]+'").tokenInput("'+autocomplete_department_users_path(current_department, :classes => options[:classes])+'", {
            prePopulate: ['+json_string+'],
            hintText: "'+options[:hint_text]+'",
            classes: {
              '+style+'
            }
          });
        });'
    if options[:include_headers]
      content_for :head, javascript_include_tag('jquery.tokeninput')
      content_for :head, stylesheet_link_tag(css_file)
    end
    text_field_tag(options[:id])
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
    output + "</select>"
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
    @default_start_date = Time.now.to_date
    @repeating_event.start_time ||= @default_start_date.to_time + current_department.department_config.schedule_start.minutes
    @repeating_event.end_time ||= @default_start_date.to_time + current_department.department_config.schedule_end.minutes
    @range_start_time = Time.now.to_date + current_department.department_config.schedule_start.minutes
    @range_end_time = Time.now.to_date + current_department.department_config.schedule_end.minutes
    if params[:location_id] #this param comes from the timeline on creation of a new repeating_event
      @repeating_event.location_ids = [] << params[:location_id]
    end
  end

	def observe_fields(fields)
		#prepare a value of the :with parameter
		with = "'"
		for field in fields
			with += field + "=’$(’#" + field + "’).is(':checked')"
			with += " + " if field != fields.last
		end
 		with += "'"
		#generate a call of the observer_field helper for each field
		ret = "";
		for field in fields
			puts field
			ret += observe_field(field.to_s, :url => {:controller => :templates, :action => "update_locations"}, :with => with, :on => "change")
    end
    return ret
	end
	
  def navbar_highlight(controller_name)
    navbar_hash = Hash[ "dashboard" => ["dashboard"],
                        "departments" => ["departments", "app_configs", "superusers", "department_configs", "application"],
                        "users" => ["users", "roles", "user_profiles", "user_profile_fields"],
                        "shifts" => ["shifts", "locations", "loc_groups", "calendars", "templates", "links", "notices", "data_objects", "stats", "announcements", "calendar_feeds", "data_entries", "data_fields", "data_types", "repeating_events", "report_items", "stickies", "tasks", "reports"],
                        "payforms" => ["payforms", "payform_items", "punch_clocks", "punch_clock_sets", "payform_item_sets"]]
    navbar_hash.select{|key, value| value.include?(controller_name) }.flatten.first
  end
end