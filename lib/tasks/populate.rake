namespace :db do
  desc "Erase and fill database"

  task :populate => :load_fixtures do
    task_start_time = Time.now

    require 'populator'
    require 'faker'

    # Edit these to change amount of data generated
    # The number of objects of any class can be either an integer or a range
    number_of_users = 10..20
    categories_per_department = 4..6
    stickies_per_department = 50
    announcements_per_department = 50
    # The following range gives start dates for stickies
    notices_start_range = 4.months.ago..4.months.from_now
    loc_groups_per_department = 3..5
    locations_per_loc_group = 2..3
    # If you don't want the priority to be set, (might create fewer shifts), then set the following to nil
    location_priority = 1..5
    max_number_of_shifts_per_time_slot = 20
    # will generate payforms starting at the below date until current; may use relative or absolute time
    payforms_beginning_date = 4.months.ago.to_date
    payform_items_per_payform = 4..6
    # how many day's worth of shifts to generate
    shifts_end_date = 4.days.from_now.to_date


    # Start of code
    puts "emptying database"
    [Department, DepartmentConfig, Category, LocGroup, Location, Payform, PayformItem, TimeSlot, Shift, SubRequest, Notice].each do |model|
      model.delete_all
    end

    puts "creating departments and configuring payform settings"
    Department.create(:name => "STC", :created_at => 2.years.ago)
      # weekly
    dept = Department.create(:name => "Film studies", :created_at => 2.years.ago)
      dept.department_config.update_attributes({:monthly => true, :end_of_month => true}) # monthly
#    dept = Department.create(:name => "Economics", :created_at => 2.years.ago)
#      dept.department_config.update_attributes({:complex => true}) # biweekly
#    dept = Department.create(:name => "Political science", :created_at => 2.years.ago)
#      dept.department_config.update_attributes({:monthly => true, :complex => true, :day => 16}) # semi-monthly

    puts "creating users and adding users to departments"
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
      puts "creating categories for #{department.name} department"
      Category.populate(categories_per_department) do |category|
        category.name = Populator.words(1..3).titleize
        category.active = true
        category.department_id = department.id
      end

      puts "creating stickies and announcements for #{department.name} department"
      Notice.populate(stickies_per_department) do |sticky|
        sticky.sticky = true
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
        announcement.sticky = false
        announcement.content = Populator.sentences(1..3)
        announcement.author_id = department.users[rand(department.users.length)].id
        announcement.start_time = notices_start_range
        announcement.end_time = rand(3) == 0 ? nil : announcement.start_time + (3 + rand(200)).days
        announcement.department_id = department.id
        announcement.created_at = announcement.start_time
      end

      puts "creating location groups and locations for #{department.name} department"
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

    puts "adding viewers for stickies and announcements"
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

    puts "creating payforms and payform items from #{payforms_beginning_date} to now"
    User.all.each do |user|
      puts "\tfor #{user.name}"
      date = Date.today
      while date > payforms_beginning_date
        user.departments.each do |department|
          end_date = Payform.default_period_date(date, department)
          unless Payform.exists?({:date => end_date, :department_id => department.id, :user_id => user.id})
            payform = Payform.build(department, user, date)

            PayformItem.populate(payform_items_per_payform) do |payform_item|
              categories = department.categories.all
              payform_item.category_id = categories[rand(categories.length)].id
              payform_item.user_id = user.id
              payform_item.payform_id = payform.id
              payform_item.active = true
              hours = [0.5]
              while hours.last < 7.0
                hours << (hours.last + 0.1).round(1)
              end
              # each payform's hours range from 0.5 to 7.0, with increments of 0.1
              payform_item.hours = hours
              payform_item.date = payform.start_date..end_date
              payform_item.description = Populator.sentences(1..3)
            end

            if payform.date < Date.today && rand(4) != 0
              payform.update_attribute(:submitted, (payform.date + 1.day).to_time)
              unless rand(3) == 0
                payform.update_attributes({:approved => payform.submitted + 1.day,
                                           :approved_by_id => department.users[rand(department.users.length)].id
                })
                if rand(2) == 0
                  payform.update_attribute(:printed, payform.approved + 10.minutes)
                end
              end
            end

          end
        end
        date -= 7.days #decrements date
      end
    end


# For each department, for each day from now until some time in the future, 1 time slot is created from 9AM to 11PM
    puts "creating a timeslot from 9AM to 11PM and populating the timeslot with shifts and sub requests"
    Department.all.each do |department|
      increment = department.department_config.time_increment
      raise "this department's time increment does not divide into 60" unless 60 % increment == 0
      blocks_per_hour = 60 / increment
      increment_seconds = increment * 60

      department.loc_groups.all.each do |loc_group|
        loc_group.locations.all.each do |location|
          (Date.today..shifts_end_date).each do |day|
            puts "\tfor department #{department.name}, location #{location.short_name}, on #{day}"

            start_time = Time.parse("9AM -0400 #{day.to_s}")
            end_time = Time.parse("11PM -0400 #{day.to_s}")
            TimeSlot.create(:location_id => location.id, :start => start_time,
                            :end => end_time, :created_at => day.to_datetime)

            max_number_of_shifts_per_time_slot.times do
              start_hour = 9 + rand(14)
              start_minute = increment * rand(blocks_per_hour)
              start_time = "#{start_hour}:#{start_minute}, #{day}".to_time
              end_time = start_time + (increment * (1 + rand(6 * blocks_per_hour))).minutes
              user = department.users[rand(department.users.length)]
              shift = Shift.new(:start => start_time, :end => end_time, :user_id => user.id,
                                :location_id => location.id, :scheduled => true,
                                :created_at => day.to_datetime + 30.minutes)
              shift.save unless shift.exceeds_max_staff?
              if !shift.new_record? && rand(10) == 0
                # shift_chunks is the number of smallest shift chunks in the length of the shift
                # this next bit is confusing so don't mess with it
                shift_chunks = ((shift.end - shift.start) / increment_seconds).round
                start_time = shift.start + (increment * rand(shift_chunks)).minutes
                chunks_left = ((shift.end - start_time) / increment_seconds).round
                end_time = start_time + (increment * (1 + rand(chunks_left))).minutes
                request_chunks = ((end_time - start_time) / increment_seconds).round
                mandatory_start = start_time + (increment * rand(request_chunks)).minutes
                request_chunks_left = ((end_time - mandatory_start) / increment_seconds).round
                mandatory_end = mandatory_start + (increment * (1 + rand(request_chunks_left))).minutes
                sub_request = SubRequest.create(:shift_id => shift.id, :reason => Populator.sentences(1..3),
                                                :start => start_time, :end => end_time,
                                                :mandatory_start => mandatory_start,
                                                :mandatory_end => mandatory_end)
                # each sub request has 1/2 chance of being taken
                if !sub_request.new_record? && rand(2) == 0
                  user = department.users[rand(department.users.length)]
                  begin
                    SubRequest.take(sub_request, user, rand(2) == 0 ? true : false)
                  rescue
                    puts "An exception was raised while trying to take the sub request\n#{$!}"
                  end
                end
              end
            end
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

