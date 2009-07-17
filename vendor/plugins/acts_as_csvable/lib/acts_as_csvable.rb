# A general wrapper for the Exceptions used by ActsAsCSVable. 
# === Module Variables
# <tt>allow_dynamic_import_template_generation</tt> - If no import template is found that matches the header
# rows of the import file, it will "dynamically create" an import template if, and only if, +all+ of the header names
# easily map to writer methods on your model. This might be useful for when you have dynamically generated user selected
# templates. This is set to <em>false</em> by default!
#
module ActsAsCSVable#:nodoc:
  class ActsAsCSVableException < Exception; end#:nodoc:
  class UnknownExportTemplateException < ActsAsCSVableException; end#:nodoc:
  class UnknownImportTemplateException < ActsAsCSVableException; end#:nodoc:
  class MissingGemException < ActsAsCSVableException; end#:nodoc:
  class MissingImportTemplateException < ActsAsCSVableException; end#:nodoc:
    
  mattr_accessor :allow_dynamic_import_template_generation
end # ActsAsCSVable