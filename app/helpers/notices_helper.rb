module NoticesHelper
  def show_notice_archive
    if params[:show_inactive].nil?
      link_to "Show Inactive Notices", :show_inactive => true
    else
      link_to "Hide Inactive Notices", notices_path
      unless Notice.inactive.empty?
        concat('<fieldset class ="index">')
          concat('<legend>Inactive Notices</legend>')
          render (:partial => 'notice', :collection => Notice.inactive)
        concat("<fieldset>")
      end
    end
  end
end

