class Object
  def to_sql
    ActiveRecord::Base.connection.quote(self)
  end
end

class Symbol
  def to_sql_column
    ActiveRecord::Base.connection.quote_column_name(self)
  end
end
