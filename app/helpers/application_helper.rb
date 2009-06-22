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
end

