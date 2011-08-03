#we need this in payform_item's form to make the drop-down list of dates accept day of the week. For whatever reason, collection_select can't apply any to_s transformations like the ones below
class Date
  def to_weekday_date
    strftime("%A, %B %d")
  end
end

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
  :us_icaldate => "%Y%m%dT%H%M%S",
  :us_icaldate_utc => "%Y%m%dT%H%M%SZ",
  :task_date => "%d %B, %a",
  :date_with_year => "%A, %B %d %Y"
}

Time::DATE_FORMATS.merge!(my_formats)
Date::DATE_FORMATS.merge!(my_formats)

