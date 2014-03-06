namespace :db do
  desc "Randomize existing User names and emails"

  task :fake_users => :environment do
    task_start_time = Time.now

    require 'faker'

    puts "renaming user names, emails, netids (login) and employee ids and removing profile photos"
    User.all.each do |user|
      user.first_name = Faker::Name.first_name
      user.last_name = Faker::Name.last_name
      user.login = user.first_name.downcase.first + user.last_name.downcase.first + (6 + rand(994)).to_s
      user.email = Faker::Internet.email(user.first_name + ' ' + user.last_name)
      user.employee_id = Faker::Number.number(5)
      if !user.save
        puts "User id #{user.id} not saved! The error message:"
        user.errors.full_messages.each do |message|
          puts message
        end
      end
      user.user_profile.photo.clear
      if !user.user_profile.save
        puts "User id #{user.id} photo not removed! The error message:"
        user.user_profile.errors.full_messages.each do |message|
          puts message
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

