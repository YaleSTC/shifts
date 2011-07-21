# Use this file to easily define all of your cron jobs.
#
# It's helpful, but not entirely necessary to understand cron before proceeding.
# http://en.wikipedia.org/wiki/Cron

# Example:
#
# set :cron_log, "/path/to/my/cron_log.log"
#
# every 2.hours do
#   command "/usr/bin/some_great_command"
#   runner "MyModel.some_method"
#   rake "some:great:rake:task"
# end
every :sunday, :at => '9am' do
  command "bundle exec rake email:payform_reminders RAILS_ENV=production"
  command "bundle exec rake email:late_payform_warnings RAILS_ENV=production"
end

every 1.day, :at => '1am' do 
 command "bundle exec rake email:daily_stats RAILS_ENV=production"
 command "bundle exec rake db:populate_missed_tasks RAILS_ENV=production"
end

every 10.minutes do
  command "bundle exec rake email:stale_shift_reminders RAILS_ENV=production"
  command "bundle exec rake db:update_shift_stats RAILS_ENV=production"
end

every 3.minutes do
  command "/usr/bin/ar_sendmail -o --chdir #{rails_root} --environment production "
end

