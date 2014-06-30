namespace :db do
  desc "Change all location report emails to fake addresses"

  task :fake_location_report_emails => :environment do
    task_start_time = Time.now

    puts "Start changing emails..."
    Location.all.each do |location|
      if location.has_attribute?(:report_email)
        name=location.report_email.split('@')[0]
        location.report_email=name+'@shifts.app'
        if !location.save(validate: false)
          puts "Location #{location.name} not saved! The error message:"
          location.errors.full_messages.each do |message|
            puts message
          end
        end
      end
    end

    def length_of_time_to_s(seconds)
      seconds = seconds.round
      return "#{seconds} sec" if seconds / 60 < 1
      minutes = seconds / 60
      seconds = seconds % 60
      return "#{minutes} min #{seconds} sec" if minutes / 60 < 1
      hours = minutes / 60
      minutes = minutes % 60
      return "#{hours} hr #{minutes} min #{seconds} sec" if hours / 24 < 2
      days = hours / 24
      hours = hours % 24
      return "#{days} days #{hours} hr #{minutes} min #{seconds} sec"
    end

    puts "rake task completed at #{Time.now}"
    puts "runtime: #{length_of_time_to_s(Time.now - task_start_time)}"
  end
end
