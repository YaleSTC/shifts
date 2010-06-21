# Add commonly used time format here. Usage: time_object.to_s(:am_pm) or :short_name, or etc. -H
my_formats = {
  :am_pm => "%I:%M %p",
  :am_pm_long => "%b %d, %Y %I:%M %p",
  :am_pm_long_no_comma => "%I:%M %p %b %d (%Y)",
  :twelve_hour => "%I:%M",
  :short_name => "%a, %b %d, %I:%M %p",
  :just_date => "%a, %b %d",
  :just_date_long => "%A, %B %d",
  :day => "%a",
  :Day => "%A",
  :gg => "%a %m/%d",
  :sql => "%Y-%m-%d %H:%M:%S",
  :us_icaldate => "%Y%m%dT%H%M%S"
}

ActiveSupport::CoreExtensions::Time::Conversions::DATE_FORMATS.merge!(my_formats)
ActiveSupport::CoreExtensions::Date::Conversions::DATE_FORMATS.merge!(my_formats)
