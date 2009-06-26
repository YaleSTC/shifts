class Array
  
  # Should probably only be called on an array of strings
  def remove_blank
    compact.delete_if{|e|e.blank?}
  end
  
end
