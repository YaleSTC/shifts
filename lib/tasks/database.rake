#for heroku: enable 'heroku rake db:purge'
require 'rake'

namespace :db do
  desc "Purges the tables of a postgres DB" 
  task :purge do
    load 'config/environment.rb'
    abcs = ActiveRecord::Base.configurations
    case abcs[RAILS_ENV]["adapter"]
    when 'postgresql'
      ActiveRecord::Base.establish_connection(abcs[RAILS_ENV])
      postgres_tables_query = %|SELECT n.nspname as "Schema", c.relname as "Name", CASE c.relkind WHEN 'r' THEN 'table' WHEN 'v' THEN 'view' WHEN 'i' THEN 'index' WHEN 'S' THEN 'sequence' WHEN 's' THEN 'special' END as "Type", u.usename as "Owner" FROM pg_catalog.pg_class c LEFT JOIN pg_catalog.pg_user u ON u.usesysid = c.relowner LEFT JOIN pg_catalog.pg_namespace n ON n.oid = c.relnamespace WHERE c.relkind IN ('r','') AND n.nspname NOT IN ('pg_catalog', 'pg_toast') AND pg_catalog.pg_table_is_visible(c.oid) ORDER BY 1,2;|
      conn = ActiveRecord::Base.connection
      conn.execute(postgres_tables_query).each { |b| puts "Deleting table: #{b[1]}"; conn.execute("DROP TABLE #{b[1]}"); }
    else
      raise "Task not supported by '#{abcs[RAILS_ENV]['adapter']}'"
    end
  end
end 