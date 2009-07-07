namespace :db do
  desc "Erase and fill database"

  task :populate => :load_fixtures do
    require 'populator'
    require 'faker'
    require 'yaml'

    # Edit these to change amount of data generated
    # The number of objects of any class can be either an int or a range
    number_of_users = 50..200
    stickies_per_department = 50
    announcements_per_department = 50
    # The following range gives start dates for stickies
    notices_start_range = 4.months.ago..4.months.from_now
    loc_groups_per_department = 3..5
    locations_per_loc_group = 2..3
    # If you don't want the priority to be set, (might create fewer shifts), then set the following to nil
    location_priority = 1..5
    max_number_of_shifts_per_time_slot = 20


    # Start of code

    [Department, LocGroup, Location, TimeSlot, Shift, Notice].each do |model|
      model.delete_all
    end

    Department.create(:name => "STC", :monthly => false, :complex => false,
                      :day => 6, :created_at => 2.years.ago)
    Department.create(:name => "Film studies", :monthly => true, :complex => false,
                      :day => 1, :created_at => 2.years.ago)
#    Department.create(:name => "Economics", :monthly => false, :complex => true,
#                      :day => 6, :created_at => 2.years.ago)
#    Department.create(:name => "Political science", :monthly => true, :complex => true,
#                      :day => 1, :day2 => 15, :created_at => 2.years.ago)


    User.populate(number_of_users) do |user|
      user.first_name = Faker::Name.first_name
      user.last_name = Faker::Name.last_name
      user.login = user.first_name.downcase.first + user.last_name.downcase.first + (6 + rand(994)).to_s
      user.email = user.login + "@example.com"
      user.perishable_token = ""
      user.created_at = Department.first.created_at
    end

    User.all.each do |user|
      # Adds users to (possibly multiple) departments
      begin
        Department.all[rand(Department.all.length)].users << user
      end while rand(10) == 0
    end

    Department.all.each do |department|
      # creates stickies
      Notice.populate(stickies_per_department) do |sticky|
        sticky.is_sticky = true
        sticky.content = Populator.sentences(1..3)
        sticky.author_id = department.users[rand(department.users.length)].id
        sticky.start_time = notices_start_range
        end_time = sticky.start_time + (3 + rand(200)).days
        sticky.end_time = end_time > Time.now ? end_time : nil
        sticky.department_id = department.id
        if sticky.end_time
          sticky.remover_id = department.users[rand(department.users.length)].id
        end
        sticky.created_at = sticky.start_time
      end

      Notice.populate(announcements_per_department) do |announcement|
        announcement.is_sticky = false
        announcement.content = Populator.sentences(1..3)
        announcement.author_id = department.users[rand(department.users.length)].id
        announcement.start_time = notices_start_range
        announcement.end_time = rand(3) == 0 ? nil : announcement.start_time + (3 + rand(200)).days
        announcement.department_id = department.id
        announcement.created_at = announcement.start_time
      end

      LocGroup.populate(loc_groups_per_department) do |loc_group|
        loc_group.name = Populator.words(1..3).titleize
        loc_group.department_id = department.id
        view_perm = Permission.create(:name => loc_group.name + " view")
        loc_group.view_perm_id = view_perm.id
        signup_perm = Permission.create(:name => loc_group.name + " signup")
        loc_group.signup_perm_id = signup_perm.id
        admin_perm = Permission.create(:name => loc_group.name + " admin")
        loc_group.admin_perm_id = admin_perm.id
        loc_group.created_at = department.created_at

        Location.populate(locations_per_loc_group) do |location|
          location.name = Populator.words(1..3).titleize
          location.short_name = location.name.split.first
          location.min_staff = 0..1
          location.max_staff = location.min_staff + rand(3)
          location.priority = location_priority
          location.active = true
          location.loc_group_id = loc_group.id
          location.created_at = loc_group.created_at
        end
      end
    end

    Notice.all.each do |notice|
      department = Department.find(notice.department_id)

      if !notice.is_sticky && rand(15) == 0
        notice.departments << department
      else

        begin
          # adds specific users to view each notice
          user = department.users[rand(department.users.length)]
          notice.users << user
        end until rand(10) == 0

        until rand(3) == 0
          # adds locations to a notice
          location = department.locations[rand(department.locations.length)]
          notice.locations << location
        end

        until rand(2) == 0
          # adds location groups to a notice
          loc_group = department.loc_groups[rand(department.loc_groups.length)]
          notice.loc_groups << loc_group
        end

      end
    end


# For each department, for each day from now until some time in the future, 1 time slot is created from 9AM to 11PM
    Department.all.each do |department|
      department.loc_groups.all.each do |loc_group|
        loc_group.locations.all.each do |location|
          (Date.today..4.days.from_now.to_date).each do |day|
            start_time = ("9AM " + day.to_s).to_time.localtime
            end_time = ("11PM " + day.to_s).to_time.localtime
            TimeSlot.create(:location_id => location.id, :start => start_time,
                            :end => end_time, :created_at => day.to_datetime)

            max_number_of_shifts_per_time_slot.times do
              start_hour = 9 + rand(14)
              start_minute = 15 * rand(4)
              start_time = "#{start_hour}:#{start_minute}, #{day}".to_time.localtime
              end_time = start_time + (15 * (1 + rand(20))).minutes
              user = department.users[rand(department.users.length)]
              Shift.create(:start => start_time, :end => end_time, :user_id => user.id,
                           :location_id => location.id, :scheduled => true,
                           :created_at => day.to_datetime + 30.minutes)
            end
          end
        end
      end
    end

    Shift.all.each do |shift|
      if rand(20) == 0
        # shift_chunks is the number of 15 minute chunks in the length of the shift
        shift_chunks = ((shift.end - shift.start) / 900).round
        start_time = shift.start + (15 * rand(shift_chunks)).minutes
        chunks_left = ((shift.end - start_time) / 900).round
        end_time = start_time + (15 * (1 + rand(chunks_left))).minutes
        request_chunks = ((end_time - start_time) / 900).round
        mandatory_start = start_time + (15 * rand(request_chunks)).minutes
        request_chunks_left = ((end_time - mandatory_start) / 900).round
        mandatory_end = mandatory_start + (15 * (1 + rand(request_chunks_left))).minutes
        SubRequest.create(:shift_id => shift, :reason => Populator.sentences(1..3),
                          :start => start_time, :end => end_time, :mandatory_start => mandatory_start,
                          :mandatory_end => mandatory_end)
      end
    end

  end
end

