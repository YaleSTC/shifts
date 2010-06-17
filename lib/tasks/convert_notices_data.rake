namespace :db do
  desc "Convert notices data to refactored format"

  task :convert_notices => :environment do
    Notice.all.each do |notice|
      if notice.sticky
        notice.type = "Sticky"
      elsif notice.useful_link
        notice.type = "Link"
      else
        notice.type = "Announcement"
      end
      notice.save
    end
  end
end