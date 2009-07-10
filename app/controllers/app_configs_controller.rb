class AppConfigsController < ApplicationController
  before_filter :require_superuser

  def edit
    @app_config = AppConfig.first
  end

  def update
    @app_config = AppConfig.first
    if @app_config.update_attributes(params[:app_config])
      flash[:notice] = "Successfully updated appconfig."
    end
    render :action => 'edit'
  end
end
