# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper

  def link_to_post_a_new_notice
    link_to_unless_current('Post a new notice', new_notice_path(:height => 530, :width => 530), :class => "thickbox")
  end

  def link_toggle(id, name, speed = "medium")
    # "<a href='#' onclick=\"Element.toggle('%s'); return false;\">%s</a>" % [id, name]
    link_to_function name, "$('##{id}').slideToggle('#{speed}')"
    # link_to_function name, "Effect.toggle('#{id}', 'appear', { duration: 0.3 });"
  end

  def early_late_info(start)
    now = Time.now
    m = distance_of_time_in_words(now - start)
    m += (now > start) ? " ago" : " later"
  end

  def return_to_shift_report_if_needed
    if (current_shift = current_user.current_shift)
      (link_to "Return to your current shift", shift_path(current_shift)) + "<br/>"
    end
  end

  def tokenized_users_autocomplete(object, field, id)
    json_string = ""
    unless object.nil? or field.nil?
      object.send(field).each do |user_source|
        json_string += "{name: '#{user_source.name}', id: '#{user_source.class}||#{user_source.id}'},\n"
      end
    end

    '<script type="text/javascript">
        $(document).ready(function() {
            $("#'+id+'").tokenInput("'+autocomplete_department_users_path(current_department)+'", {
                prePopulate: ['+json_string+'],
                classes: {
                    tokenList: "token-input-list-facebook",
                    token: "token-input-token-facebook",
                    tokenDelete: "token-input-delete-token-facebook",
                    selectedToken: "token-input-selected-token-facebook",
                    highlightedToken: "token-input-highlighted-token-facebook",
                    dropdown: "token-input-dropdown-facebook",
                    dropdownItem: "token-input-dropdown-item-facebook",
                    dropdownItem2: "token-input-dropdown-item2-facebook",
                    selectedDropdownItem: "token-input-selected-dropdown-item-facebook",
                    inputToken: "token-input-input-token-facebook"
                }
            });
        });
        </script>' + text_field_tag(id)
  end


  def select_integer (object, column, start, stop, default = nil)
    output = "<select id=\"#{object}_#{column}\" name=\"#{object}[#{column}]\">"
    for i in start..stop
      output << "\n<option value=\"#{i}\""
      output << " selected=\"selected\"" if i == default
      output << ">#{i}"
    end
    output + "</select>"
  end

end

