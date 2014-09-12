require 'rails_helper'
 
RSpec.describe AppConfigsController, type: :controller do
  fixtures :all
  integrate_views
  
  it "index action should render index template" do
    get :index
    response.should render_template(:index)
  end
  
  it "show action should render show template" do
    get :show, id: AppConfig.first
    response.should render_template(:show)
  end
  
  it "new action should render new template" do
    get :new
    response.should render_template(:new)
  end
  
  it "create action should render new template when model is invalid" do
    AppConfig.any_instance.stubs(:valid?).returns(false)
    post :create
    response.should render_template(:new)
  end
  
  it "create action should redirect when model is valid" do
    AppConfig.any_instance.stubs(:valid?).returns(true)
    post :create
    response.should redirect_to(app_config_url(assigns[:app_config]))
  end
  
  it "edit action should render edit template" do
    get :edit, id: AppConfig.first
    response.should render_template(:edit)
  end
  
  it "update action should render edit template when model is invalid" do
    AppConfig.any_instance.stubs(:valid?).returns(false)
    put :update, id: AppConfig.first
    response.should render_template(:edit)
  end
  
  it "update action should redirect when model is valid" do
    AppConfig.any_instance.stubs(:valid?).returns(true)
    put :update, id: AppConfig.first
    response.should redirect_to(app_config_url(assigns[:app_config]))
  end
  
  it "destroy action should destroy model and redirect to index action" do
    app_config = AppConfig.first
    delete :destroy, id: app_config
    response.should redirect_to(app_configs_url)
    AppConfig.exists?(app_config.id).should be_false
  end
end
