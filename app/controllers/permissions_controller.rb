class PermissionsController < ApplicationController
  before_filter :require_superuser
  
  def index
    @permissions = Permission.all
  end
end
