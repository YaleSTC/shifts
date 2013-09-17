class AppConfigsController < ApplicationController
  before_filter :require_superuser

  def edit
    @app_config = AppConfig.all.first
  end

  def update
    @app_config = AppConfig.all.first
    use_ldap = params[:app_config][:use_ldap] && params[:app_config][:use_ldap]=="1"
    if @app_config.update_attributes(params[:app_config].merge({:use_ldap=>use_ldap}))
      flash[:notice] = "Successfully updated appconfig."
    end
    render :action => 'edit'
  end
end
