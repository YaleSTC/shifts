require 'acts_as_csvable.rb'
require 'acts_as_csv_exportable'
require 'acts_as_csv_importable'

ActsAsCSVable.allow_dynamic_import_template_generation = false

begin
  require 'fastercsv'
rescue Exception
  begin
    require 'csv'
  rescue Exception
    raise ActsAsCSVable::MissingGemException.new("ActsAsCSVable requires either the FasterCSV or CSV gem")
  end
end
  
require 'array'

ActiveRecord::Base.class_eval do
  include ActsAsCSVExportable::ActiveRecord::Exporting
  include ActsAsCSVImportable::ActiveRecord::Importing
end


require 'action_controller' #to load Mime module
# add the csv MimeType
Mime::Type.register 'text/csv', :csv, %w(text/comma-separated-values)

