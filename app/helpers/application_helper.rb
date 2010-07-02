# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper

  def link_toggle(id, name, speed = "slow")
    # "<a href='#' onclick=\"Element.toggle('%s'); return false;\">%s</a>" % [id, name]
    link_to_function name, "$('##{id}').slideToggle('#{speed}')"
    # link_to_function name, "Effect.toggle('#{id}', 'appear', { duration: 0.3 });"
  end

	def link_to_post_a_link
		if current_user.is_loc_group_admin?(current_department) || current_user.is_admin_of?(current_department)
    	link_to_unless_current('Post a new link', new_link_path(:height => "330", :width => 515, :type => "link"), :title => "Post a new link", :class => "thickbox", :id => "post_link" )
		end
  end

	def link_to_post_a_sticky(on_report_page = false)
		on_report_page == true ? height = 240 : height = 500
    link_to_unless_current('Post a new sticky', new_sticky_path(:height => "#{height}", :width => 515, :type => "Sticky"), :title => "Post a new sticky", :class => "thickbox", :id => "post_link" )
  end

	def link_to_post_an_announcement
		if current_user.is_loc_group_admin?(current_department) || current_user.is_admin_of?(current_department)
			link_to_unless_current('Post a new announcement', new_announcement_path(:height => 535, :width => 515), :title => "Post a new announcement", :class => "thickbox", :id => "announcement_link")
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
      :style => "vertical" #default to vertical style -- seems more appropriate
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
        $("#'+options[:id]+'").tokenInput("'+autocomplete_department_users_path(current_department)+'", {
            prePopulate: ['+json_string+'],
            hintText: "'+options[:hint_text]+'",
            classes: {
              '+style+'
            }
          });
        });'
    content_for :head, javascript_include_tag('jquery.tokeninput')
    content_for :head, stylesheet_link_tag(css_file)
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

  #TODO: clean up datepicker references, since datepicker.js has been removed (for license reasons, I think)
  def unobtrusive_datepicker_includes
    #javascript 'datepicker'
    #stylesheet 'datepicker'
  end

  def unobtrusive_datepicker_include_tags
    #(javascript_include_tag 'datepicker') + (stylesheet_link_tag 'datepicker')
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

end

