# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
  def make_popup(hash)
    hash[:width] ||= 600
    "Modalbox.show(this.href, {title: '#{hash[:title]}', width: #{hash[:width]}}); return false;"
  end
end

