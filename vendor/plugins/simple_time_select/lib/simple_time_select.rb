module ActionView::Helpers
  class DateTimeSelector
     def select_minute_with_simple_time_select
        return select_minute_without_simple_time_select unless @options[:simple_time_select].eql? true


        @options[:time_separator] = ""
        @options[:include_start_time] = true  if @options[:include_start_time].nil?
        @options[:include_end_time] = false   if @options[:include_end_time].nil?


        # Default is 15 minute intervals
        minute_interval = 15
        if @options[:minute_interval]
          minute_interval = @options[:minute_interval]
        end


        if @options[:start_time]
          start_minute = @options[:start_time].hour * 60 + @options[:start_time].min
        else
          start_minute = 0
        end
        start_minute = start_minute + 1 unless @options[:include_start_time]

        if @options[:end_time]
          end_minute = @options[:end_time].hour * 60 + @options[:end_time].min
          end_minute += 1440    if (@options[:end_time].day == (@options[:start_time].day + 1))
        else
          end_minute = 1439
        end
        end_minute = end_minute - 1 unless @options[:include_end_time]




        if @options[:default]
          val_minutes = @options[:default].min + @options[:default].hour*60
          if (@options[:end_time].to_date == (@options[:start_time].to_date + 1.day)) && (val_minutes < start_minute)
            val_minutes += 1440
          end
          # Even if :default isn't a valid multiple of 15, it should still be used
          # This condition selects the earliest valid minute after :default to be the default
          unless (@options[:default].min % minute_interval) == 0
            val_minutes = val_minutes - (@options[:default].min % minute_interval) + minute_interval
          end
        end


        if @options[:use_hidden] || @options[:discard_minute]
          build_hidden(:minute, val)
        else
          minute_options = []
          start_minute.upto(end_minute) do |minute|

            if minute < 1440
              if minute%minute_interval == 0
                ampm = minute < 720 ? ' AM' : ' PM'
                hour = minute/60
                minute_padded = zero_pad_num(minute%60)
                hour_padded = zero_pad_num(hour)
                ampm_hour = ampm_hour(hour)
                val = "#{hour_padded}:#{minute_padded}:00"
                minute_options << ((val_minutes == minute) ?
                  %(<option value="#{val}" selected="selected">#{ampm_hour}:#{minute_padded}#{ampm}</option>\n) :
                  %(<option value="#{val}">#{ampm_hour}:#{minute_padded}#{ampm}</option>\n)
                )
              end
            elsif minute < 2880
              minute -= 1440
              if minute%minute_interval == 0
                ampm = minute < 720 ? ' AM' : ' PM'
                hour = minute/60
                minute_padded = zero_pad_num(minute%60)
                hour_padded = zero_pad_num(hour)
                ampm_hour = ampm_hour(hour)
                val = "#{hour_padded}:#{minute_padded}:00+"
                minute_options << ((val_minutes == minute + 1440) ?
                  %(<option value="#{val}" selected="selected">#{ampm_hour}:#{minute_padded}#{ampm}*</option>\n) :
                  %(<option value="#{val}">#{ampm_hour}:#{minute_padded}#{ampm}*</option>\n)
                )

              end
            end

          end
          build_select(:minute, minute_options)
        end
      end
      alias_method_chain :select_minute, :simple_time_select


      def select_hour_with_simple_time_select
        return select_hour_without_simple_time_select unless @options[:simple_time_select].eql? true
        # Don't build the hour select
        #build_hidden(:hour, val)
      end
      alias_method_chain :select_hour, :simple_time_select

      def select_second_with_simple_time_select
        return select_second_without_simple_time_select unless @options[:simple_time_select].eql? true
        # Don't build the seconds select
        #build_hidden(:second, val)
      end
      alias_method_chain :select_second, :simple_time_select

      def select_year_with_simple_time_select
        return select_year_without_simple_time_select unless @options[:simple_time_select].eql? true
        # Don't build the year select
        #build_hidden(:year, val)
      end
      alias_method_chain :select_year, :simple_time_select

      def select_month_with_simple_time_select
        return select_month_without_simple_time_select unless @options[:simple_time_select].eql? true
        # Don't build the month select
        #build_hidden(:month, val)
      end
      alias_method_chain :select_month, :simple_time_select

      def select_day_with_simple_time_select
        return select_day_without_simple_time_select unless @options[:simple_time_select].eql? true
        # Don't build the day select
        #build_hidden(:day, val)
      end
      alias_method_chain :select_day, :simple_time_select

  end
end

def ampm_hour(hour)
  return hour == 12 ? 12 : (hour == 0 ? 12 : (hour / 12 == 1 ? hour % 12 : hour))
end

def zero_pad_num(num)
  return num < 10 ? '0' + num.to_s : num.to_s
end

