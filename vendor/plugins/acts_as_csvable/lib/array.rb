class Array 

  # Takes elements of the array, and generates CSV for each element based on a given template / columns
  #
  def to_csv(options = {})    
    if all? { |e| e.respond_to?(:to_row) } and not empty?
      columns = options.delete(:columns)
      template = options.delete(:template)
      
      if columns.blank?
        columns = first.class.get_export_template(template)
      end
      
      columns = first.class.convert_all_elements_to_hash(columns)  
      
      header_row =  first.class.column_definitions_to_header_row(columns).to_csv
      content_rows = map { |e| e.to_row(:columns => columns) }.map(&:to_csv)
      ([header_row] + content_rows).join
    else 
      if defined? FasterCSV
        FasterCSV.generate_line(self)
      else
        buffer = ''
        CSV.generate_row(self, self.size, buffer)
        buffer
      end
    end
  end
end # end Array