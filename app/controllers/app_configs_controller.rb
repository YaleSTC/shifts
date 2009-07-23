class AppConfigsController < ApplicationController
  before_filter :require_superuser

  def edit
    @app_config = AppConfig.first
  end

  def update
    @app_config = AppConfig.first
    use_ldap = params[:use_ldap] ? true : false
    if @app_config.update_attributes(params[:app_config].merge({:use_ldap=>use_ldap}))
      flash[:notice] = "Successfully updated appconfig."
    end
    render :action => 'edit'
  end
end
