class Object
  def to_sql
    ActiveRecord::Base.connection.quote(self)
  end
end
