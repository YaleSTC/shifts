# These helper methods can be called in your template to set variables to be used in the layout
# This module should be included in all views globally,
# to do so you may need to add this line to your ApplicationController
#   helper :layout
module LayoutHelper
  def title(page_title, show_title = true)
    content_for(:title) { page_title.to_s }
    @show_title = show_title
  end

  def subtitle(subtitle)
    content_for(:subtitle) { subtitle.to_s }
  end

  def show_title?
    @show_title
  end

  # Add this to allow us to use nested layout, see layouts/users.html.erb on how to use it -H
  # This one is a fix over the method in shift app that breaks in rails > 2.1
  # If layout doesn't contain '/' then corresponding layout template
  # is searched in default folder ('app/views/layouts'), otherwise
  # it is searched relative to controller's template root directory
  # ('app/views/' by default).
  def inside_layout(layout, &block)
    layout = layout.include?('/') ? layout : "layouts/#{layout}"
    @template.instance_variable_set('@content_for_layout', capture(&block))
    concat(@template.render( file: layout, use_full_path: true ))
  end

  def tab(str)
    str == controller.controller_name ? "current_tab" : "tab"
  end

end

