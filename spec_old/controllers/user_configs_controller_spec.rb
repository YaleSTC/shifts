require File.dirname(__FILE__) + '/../spec_helper'
 
describe UserConfigsController do
  fixtures :all
  render_views
  
  it "index action should render index template" do
    get :index
    response.should render_template(:index)
  end
  
  it "show action should render show template" do
    get :show, id: UserConfig.first
    response.should render_template(:show)
  end
  
  it "new action should render new template" do
    get :new
    response.should render_template(:new)
  end
  
  it "create action should render new template when model is invalid" do
    UserConfig.any_instance.stubs(:valid?).returns(false)
    post :create
    response.should render_template(:new)
  end
  
  it "create action should redirect when model is valid" do
    UserConfig.any_instance.stubs(:valid?).returns(true)
    post :create
    response.should redirect_to(user_config_url(assigns[:user_config]))
  end
  
  it "edit action should render edit template" do
    get :edit, id: UserConfig.first
    response.should render_template(:edit)
  end
  
  it "update action should render edit template when model is invalid" do
    UserConfig.any_instance.stubs(:valid?).returns(false)
    put :update, id: UserConfig.first
    response.should render_template(:edit)
  end
  
  it "update action should redirect when model is valid" do
    UserConfig.any_instance.stubs(:valid?).returns(true)
    put :update, id: UserConfig.first
    response.should redirect_to(user_config_url(assigns[:user_config]))
  end
  
  it "destroy action should destroy model and redirect to index action" do
    user_config = UserConfig.first
    delete :destroy, id: user_config
    response.should redirect_to(user_configs_url)
    UserConfig.exists?(user_config.id).should be_false
  end
end
