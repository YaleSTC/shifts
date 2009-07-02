namespace :db do
  desc "Erase and fill database"

  task :populate => :environment do
    require 'populator'
    require 'faker'

    # Edit these if you want to change amount of data generated
    number_of_users = 20..50
    number_of_stickies_per_department = 40
    # The following range gives start dates for stickies
    stickies_start_range = 4.months.ago..4.months.from_now
    number_of_loc_groups_per_department = 3..5
    number_of_locations_per_loc_group = 2..3
    # If you don't want the priority to be set, (might create fewer shifts), then set the following to nil
    location_priority = 1..5
    max_number_of_shifts_per_time_slot = 20


    # Start of code

    [Department, User, LocGroup, Location, TimeSlot, Shift, Notice].each do |model|
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

    Department.all.each do |department|
      User.populate(number_of_users) do |user|
        user.first_name = Faker::Name.first_name
        user.last_name = Faker::Name.last_name
        user.login = user.first_name.downcase.first + user.last_name.downcase.first + (6 + rand(994)).to_s
        user.email = user.login + "@example.com"
        user.default_department_id = department.id
        user.created_at = department.created_at
      end
    end

    User.all.each do |user|
      # Adding users to departments
      Department.find(user.default_department_id).users << user

      # This next part adds users to multiple departments by chance
      while rand(10) == 0 do
        dept = Department.all[rand(Department.all.length)]
        dept.users << user
      end
    end

    Department.all.each do |department|
      Notice.populate(number_of_stickies_per_department) do |sticky|
        sticky.is_sticky = true
        sticky.content = Populator.sentences(1..3)
        sticky.author_id = department.users[rand(department.users.length)].id
        sticky.start_time = stickies_start_range
        sticky.end_time = sticky.start_time + (3 + rand(200)).days unless rand(10) == 0
        sticky.department_id = department.id
        if sticky.end_time && sticky.end_time < Time.now
          sticky.remover_id = department.users[rand(department.users.length)].id unless rand(5) == 0
        end
        sticky.created_at = sticky.start_time - 4.hours
      end

      LocGroup.populate(number_of_loc_groups_per_department) do |loc_group|
        loc_group.name = Populator.words(1..3).titleize
        loc_group.department_id = department.id
        view_perm = Permission.create(:name => loc_group.name + " view")
        loc_group.view_perm_id = view_perm.id
        signup_perm = Permission.create(:name => loc_group.name + " signup")
        loc_group.signup_perm_id = signup_perm.id
        admin_perm = Permission.create(:name => loc_group.name + " admin")
        loc_group.admin_perm_id = admin_perm.id
        loc_group.created_at = department.created_at

        Location.populate(number_of_locations_per_loc_group) do |location|
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

    Notice.all.each do |sticky|
      dept = Department.find(sticky.department_id)

      begin
        # adds users to viewer_links
        # the begin makes sure this block is run at least once, so each sticky has at least 1 viewer
        users = dept.users
        sticky.add_viewer_source(users[rand(users.length)])
      end while rand(10) != 0

      while rand(3) != 0
        # assigns display_location_links
        # each time it either adds a location or location group with equal likelyhood
        locations = dept.locations
        loc_groups = dept.loc_groups
        display_loc = rand(2) == 0 ? loc_groups[rand(loc_groups.length)] : locations[rand(locations.length)]
        sticky.add_display_location_source(display_loc)
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
              end_time = start_time + (15 * (1 + rand(12))).minutes
              user = department.users[rand(department.users.length)]
              Shift.create(:start => start_time, :end => end_time, :user_id => user.id,
                           :location_id => location.id, :scheduled => true,
                           :created_at => day.to_datetime + 30.minutes)
            end
          end
        end
      end
    end
  end
end

