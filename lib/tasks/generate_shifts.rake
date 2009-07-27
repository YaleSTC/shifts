namespace :db do
  desc "generates shifts for the users in the fixtures in preload_data"

  task :generate_shifts => :load_fixtures do
    require 'populator'

    shifts_end_date = 3.months.from_now.to_date
    max_number_of_shifts_per_time_slot = 80

    Shift.delete_all


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
  end
end

