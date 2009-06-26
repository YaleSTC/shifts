# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
  def make_popup(hash)
    hash[:width] ||= 600
    "Modalbox.show(this.href, {title: '#{hash[:title]}', width: #{hash[:width]}}); return false;"
  end

  def link_toggle(id, name, speed = "medium")
    # "<a href='#' onclick=\"Element.toggle('%s'); return false;\">%s</a>" % [id, name]
    link_to_function name, "$('##{id}').slideToggle('#{speed}')"
    # link_to_function name, "Effect.toggle('#{id}', 'appear', { duration: 0.3 });"
  end

  def thick_box_end
    parent.tb_remove()
    redirect_to notices_path
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
end

