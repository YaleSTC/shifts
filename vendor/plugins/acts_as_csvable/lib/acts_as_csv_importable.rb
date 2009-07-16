module ActsAsCSVImportable#:nodoc:
  module ActiveRecord#:nodoc:

    module Importing#:nodoc:
      def self.included(base)#:nodoc:
        base.extend(ClassMethods)
      end
      
      # == ActsAsCSVImportable
      # ActsAsCSVImporting is to facilitate the easy importing of ActiceRecord Objects by means of CSV without the need for messy
      # model specific deductions as to what to do with data, and how to import it. Simply define an acts_as_csv_importable template in
      # your model and you're good to go!
      #
      # === Usage
      #   #project.rb
      #   class Project < ActiveRecord::Base
      #     acts_as_csv_importable :new_projects, [{:project_name => :name}, {:project_description => :description}, #... 
      #     #...
      #   end
      #
      # We will use the Project model outlined above in the examples to follow:
      # 
      # Simply, using the acts_as_csv_importable templates defined in our Project model, we export
      # our subset of Project instances to csv based on user input from a form
      # 
      #   #clients_controller.rb
      #   def update_projects
      #     file = params[:csv_file]
      #     template = params[:csv_upload_template]
      #     @client = Client.find(params[:id])
      #     
      #     projects = Project.from_csv(file, template)
      #     if projects.all?(&:valid?)
      #       client.projects = projects
      #       client.save
      #       #untested caveat of doing this:
      #       #  if project has a 'validate_uniqueness_of' on any of the updated columns, and two of the 
      #       #  uploaded projects have the same value, but none in the database, your all?(&:valid) should pass
      #       #  but your save should fail! I suggest enforcing transactions around the save.
      #     else
      #       #tell user which projects are invalid...
      #     end
      #   end
      #
      module ClassMethods
        @@csv_import_templates = {}
        
        # Defines a CSV Import Template for the use of +from_csv+. 
        # Use this method in your model to flesh out a template for csv importing. Takes the same arguments as acts_as_csv_exportable
        #
        #   #project.rb
        #   class Project < ActiveRecord::Base
        #     acts_as_csv_importable :new_projects, [{:project_name => :name}, {:project_description => :description}, #... 
        #     #...
        #   end
        #
        # You can define an unlimited number of CSV import templates.
        #
        # === Notes
        # All methods listed in import templates get called with an '=' at the end. That is, their setter equivalent; don't include it
        # in your template definition.  Also, if you have some sort of has_many relationship (tags?), you can put all the tags in one
        # field with a delimiter, and then send that entire string to a method of your choice (simply define it in your model) and sort
        # out what to do with that string once it gets there.
        #
        def acts_as_csv_importable(template, column_hash_or_array)
          column_hashes = convert_all_elements_to_hash(column_hash_or_array)
          add_csv_import_template(template.to_sym, column_hashes)
        end
        
        # Used to create or update ActiveRecord Models from a CSV file. If one of the columns of the CSV is the primary key for that
        # model, the instance will be found and the data will be updated. If no primary key is filled in for that row, or no
        # primary key column is included, new instances will be instantiated.
        #
        # If no template is supplied, it is attempted to be deduced from the column headers. If no import template can be found an
        # ActsAsCSVAble::UnknownImportTemplate is raised. 
        #
        # === Usage
        #   #clients_controller.rb
        #   def update_projects
        #     file = params[:csv_file]
        #     template = params[:csv_upload_template]
        #     @client = Client.find(params[:id])
        #     
        #     projects = Project.from_csv(file, template)
        #     if projects.all?(&:valid?)
        #       client.projects = projects
        #       client.save
        #       #untested caveat of doing this:
        #       #  if project has a 'validate_uniqueness_of' on any of the updated columns, and two of the 
        #       #  uploaded projects have the same value, but none in the database, your all?(&:valid) should pass
        #       #  but your save should fail! I suggest enforcing transactions around the save.
        #     else
        #       #tell user which projects are invalid...
        #     end
        #   end
        #
        def from_csv(csv_file, template = nil)
          raise ::ActsAsCSVable::MissingGemException.new("Need FasterCSV gem to use ActsAsCSVImportable") unless defined? FasterCSV
          
          methods = get_csv_import_columns(template).map { |c| c.values.first.to_s } unless template.blank?
          
          count = 0
          objects = []
          
          FasterCSV.parse(csv_file.read) do |row|
            if count > 0 #past header row
              objects << from_csv_row(methods, row)
            else
              #if template not passed, try to find from the header row 
              methods ||= find_methods_from_header_row(row)
            end
            count += 1
          end
          return objects          
        end
       
        # This creates a blank CSV file of any of your CSV export templates. This is useful for giving users to fill out and
        # resubmit.
        #
        def csv_import_template(template = :default)
          columns = get_csv_import_columns(template)
          column_definitions_to_header_row(columns).to_csv
        end
       
        def add_csv_import_template(template, column_hashes)#:nodoc:
            @@csv_import_templates[self.to_s.to_sym] ||= {}
            @@csv_import_templates[self.to_s.to_sym][template.to_sym] = column_hashes                                                                                       
        end
        
        def get_csv_import_columns(template = :default)#:nodoc:
          if all_csv_import_templates.keys.include?(template.to_sym)
            all_csv_import_templates[template.to_sym]
          elsif template == :default
            convert_all_elements_to_hash(content_columns.map(&:name) - ['created_at', 'update_at'])
          else
            raise ::ActsAsCSVable::UnknownImportTemplateException.new("Could not find import template '#{template}'")
          end
        end
        
        def all_csv_import_templates#:nodoc:
          @@csv_import_templates[self.to_s.to_sym] || {}
        end
        
        def find_methods_from_header_row(row)#:nodoc:
          all_csv_import_templates.each do |template, hash_array|
            column_headers = column_definitions_to_header_row(hash_array)
            if column_headers == row
              return hash_array.map{|c| c.values.first.to_s }
            end
          end
          
          # if this is the default template
          if row.map {|c| c.downcase.gsub(/ /, '_')}.map(&:strip) == get_csv_import_columns(:default).map(&:values).flatten.map(&:strip)
            return get_csv_import_columns(:default).map(&:values).flatten.map(&:strip)
          end            
            
          
          if ::ActsAsCSVable.allow_dynamic_import_template_generation
            #change header row to method names...
            method_names = row.map {|e| e.downcase.gsub(/ /, '_') }
            if method_names.all? { |e|  self.new.respond_to?("#{e}=") }
              return method_names
            end
          end
        
          # if here, no import template exists for this csv
          raise ::ActsAsCSVable::MissingImportTemplateException.new("Could not find an import template for this file")
        end
        
        def column_definitions_to_header_row(columns)#:nodoc:
          columns.map { |c| c.keys.first.to_s.gsub('_', ' ').titleize }
        end
      
        def from_csv_row(methods, data_array)#:nodoc:
          data_array.each { |c| c.strip! unless c.blank? }
          
          pk_placement = 0
          if methods.include?(self.primary_key.to_s)
            methods.each_with_index do |method, i|
              if method.to_s == self.primary_key.to_s
                pk_placement == i
                break
              end
            end
          end
          #find obj in db or instantiate new
          new_obj = self.find(data_array[pk_placement]) if self.exists?(data_array[pk_placement])
          new_obj ||= new
          
          methods.each_with_index do |method, j|
            new_obj.send("#{method}=", data_array[j])
          end
          new_obj
        end
      end #end ClassMethods
    end #end Importing
  end #end ActiveRecord
end #end ActsAsCSVImportable
          