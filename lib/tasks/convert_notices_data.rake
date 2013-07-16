namespace :db do
  desc "Convert notices data to refactored format"

  task :convert_notices => :environment do
    
    #Convert notices to use STI instead of old attribute-style typing
    Notice.all.each do |notice|
      if notice.sticky
        notice.type = "Sticky"
      elsif notice.useful_link
        notice.type = "Link"
      elsif notice.announcement
        notice.type = "Announcement"
      end
      notice.save(false)
    end
    ##Convert old links
    Link.all.each do |link|
      new_link = link.content.split('|$|')
      if new_link.size == 2
        link.content = new_link[0]
        link.url = new_link[1]
        link.save!
      end
    end
  end
end