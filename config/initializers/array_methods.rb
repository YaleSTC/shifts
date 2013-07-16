class Array

  def batch(num_per_array)
    original = self
    out = []
    while original && !original.empty? do
      out.push original[0..num_per_array-1]
      original = original[num_per_array..original.length]
    end
    out
  end

  # Should probably only be called on an array of strings
  def remove_blank
    compact.delete_if{|string|string.blank?}
  end

end
