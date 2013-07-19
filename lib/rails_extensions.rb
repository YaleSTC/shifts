class Array
  # Changes an array of users to a CSV file 
  def to_csv_users
    CSV.generate do |csv|
      csv << User.csv_headers
      self.each do |user|
        csv << user.attributes.values_at(*User.csv_headers)
      end
    end
  end
end