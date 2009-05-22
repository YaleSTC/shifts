class PermissionsController < ApplicationController
  def index
    @permissions = Permission.all
  end
end
