module DataEntriesHelper

  def data_entry_class(data_entry)
    if !data_entry
      return "empty_entry"        
    elsif data_entry.passes_field_validation? 
      return "safe_entry"
    else
      return "alert_entry"
    end
  end

end
