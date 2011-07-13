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
  command "bundle exec email:payform_reminders"
  command "bundle exec email:late_payform_warnings"
end

every 1.day, :at => '1am' do 
 command "bundle exec rake email:daily_stats"
 command "bundle exec db:populate_missed_tasks"
end

every 10.minutes do
  command "bundle exec email:stale_shift_reminders"
  command "bundle exec db:update_shift_stats"
end

every 3.minutes do
  command "/usr/bin/ar_sendmail -o --chdir #{rails_root} --environment production"
end

