class StickiesController < NoticesController

  def index
		redirect_to(notices_path)
  end

  def show
     redirect_to(notices_path)
  end

  def new
    @sticky = Sticky.new
    layout_check
  end

  def create
    @sticky = Sticky.new(params[:sticky])
		@sticky.author = current_user
		@sticky.start_time = Time.now
		if params[:end_time_choice] == "indefinite"
			@sticky.end_time = nil
			@sticky.indefinite = true
		elsif params[:sticky][:end_time] == "day"
			@sticky.end_time = @sticky.start_time + 86400
		elsif params[:sticky][:end_time] == "week"
			@sticky.end_time = @sticky.start_time + 604800
		elsif params[:sticky][:end_time] == "month"
			@sticky.end_time = @sticky.start_time + 18144000
		end
		begin
      Sticky.transaction do
        @sticky.save(false)
        set_sources(@sticky)
        @sticky.save!
    	end
		rescue Exception
      respond_to do |format|
        format.html { render :action => "new" }
        format.js  #create.js.rjs
      end
    else
      respond_to do |format|
        format.html {
        flash[:sticky] = 'Sticky was successfully created.'
        redirect_to stickies_path
        }
        format.js  #create.js.rjs
      end
    end
  end

  def destroy
		redirect_to :controller => 'notice', :action => 'destroy'
	end
end
