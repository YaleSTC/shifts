module ActsAsCSVExportable#:nodoc:
  module ActiveRecord#:nodoc:
    module Exporting#:nodoc:
      
      def self.included(base)#:nodoc:
        base.extend(ClassMethods)
        base.class_eval { include InstanceMethods }
      end
      
      # == CSV Exporting
      # ActsAsCSVExportable is to facilitate the easy exporting of ActiceRecord Objects by means of CSV without the need for messy
      # CSV building and streaming in your controller. With the simple, easy to use, ActiveRecord extension, you can succinctly define
      # reusable export templates, that are accessible anywhere in your application that your model is!
      #
      # === Usage
      #     #project.rb
      #     class Project < ActiveRecord::Base
      #       acts_as_csv_exportable :default, [:id, :name, :description, { :client => "client.name"}]
      #       acts_as_csv_exportable :detailed, [:id, :name. :description, { :client => "client.name}, :projected_cost, :projected_profit, :formatted_proposed_completion_date]
      #      #...
      #     end
      # We will use the Project model outlined above in the examples to follow:
      # 
      # Simply, using the acts_as_csv_exportable templates defined in our Project model, we export
      # our subset of Project instances to csv based on user input from a form
      # 
      #   #clients_controllers.rb
      #   def projects
      #     @client = Client.find(params[:id])
      #     @projects = @client.projects
      #     template = params[:export_template]
      #
      #     responds_to do |wants|
      #       wants.html
      #       wants.csv { render :text => @projects.to_csv(:template => template) }
      #     end
      #   end
      #  
      module ClassMethods
        @@csv_export_templates = {}

        # Call this method in the model of which you would like to override default export functionality. The 
        # default template returns all content columns (+content_columns+)
        # 
        # Arrays are used to maintain order.
        # 
        #     #proposal.rb
        #     class Proposal < ActiveRecord::Base
        #       acts_as_csv_exportable :default, [:id, :name, :description, { :client => "client.name"}]
        #       acts_as_csv_exportable :detailed, [:id, :name. :description, { :client => "client.name}, :projected_cost, :projected_profit, :formatted_proposed_completion_date]
        #      #...
        #     end
        #
        #  You can define an unlimited number of csv export templates
        # ==== Specifying Columns
        # You can specify your column in multiple ways:
        # * As a symbol: The symbol will be used as both a column header and a method to call
        # * As a string: Same as symbol, but this allows you to do method chaining ("client.name")
        # * As a hash: Allows you to specify both a column header and a method ( [{:a_name => :a_method}, {:another_name => "some.chained.method"}] )
        #
        def acts_as_csv_exportable(template, column_array)
          column_hashes = convert_all_elements_to_hash(column_array)
          add_csv_export_template(template.to_sym, column_hashes)
        end
        
        # Simpy a shortcut allowing you to call 
        #   Project.to_csv(:tempate => :everything) 
        # rather than doing
        #   Project.find(:all).to_csv(:template => :everything)
        #
        def to_csv(*args)
          find(:all).to_csv(*args)   
        end
          
        # Used on the to_csv method on Array. This calls the export tempate hash to determine column
        # headers and methods to call to populate csv fields
        #
        def get_export_template(template = :default)#:nodoc:
          template ||= :default
          if all_csv_export_templates.keys.include?(template.to_sym)
            all_csv_export_templates[template.to_sym]  
          elsif template == :default
            convert_all_elements_to_hash(content_columns.map(&:name))
          else
            raise UnknownExportTemplate.new("Unknown Export Template: #{template}")  
          end  
        end
        
        # converts all elements of the template array to key => val pairs for name/method for the use
        # of the +to_row+ method. Converts arrays of hashes, arrays of strings/symbols and mixed arrays
        #
        def convert_all_elements_to_hash(column_array)#:nodoc:
          column_array.map do |element|
            if element.is_a? Hash
              element
            elsif element.is_a? String or element.is_a? Symbol
              {element => element}  
            end
          end
        end
        
        private

        # Adds an export template to the model that you can use when calling +to_csv+
        #
        def add_csv_export_template(template, column_hashes)#:nodoc:
          @@csv_export_templates[self.to_s.to_sym] ||= {}
          @@csv_export_templates[self.to_s.to_sym][template] = column_hashes
        end
        
        def all_csv_export_templates#:nodoc:
          @@csv_export_templates[self.to_s.to_sym] || {}
        end
        
        def column_definitions_to_header_row(columns)#:nodoc:
          columns.map { |c| c.keys.first.to_s.gsub('_', ' ').titleize }
        end

      end # end ClassMethods
    
      module InstanceMethods#:nodoc:
        # This returns a CSV row of an item's data. Used by Array.to_csv
        # if columns are specified, they take priority over a template
        def to_row(options = {})#:nodoc:
          template = options.delete(:template) || :default
          columns = options.delete(:columns)
          
          # columns take precedence over a template
          columns_to_export = columns.blank? ? self.class.get_export_template(template) : self.class.convert_all_elements_to_hash(columns)
          
          columns_to_export.map! do |hash_pair|
            method = hash_pair.values.first
            get_column_value(method)              
          end
          columns_to_export
        end
        
        private
        # Used by to_row to determine values to used to fill an item's row. Simply sends the method
        # to the item, breaking apart chained methods and sending those individually.
        #
        def get_column_value(method)#:nodoc:
          parts = method.to_s.split(".")
          
          response = self
          parts.each do |part|
            response = response.send(part) if response.respond_to?(part)
          end
          response = nil if response == self
          
          return response
        end
      end # end InstanceMethods
    end # end Exporting
  end # end ActiveRecord
end #end ActsAsCSVExportable