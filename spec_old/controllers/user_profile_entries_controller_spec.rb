require File.dirname(__FILE__) + '/../spec_helper'
 
describe UserProfileEntriesController do
  fixtures :all
  render_views
  
  it "index action should render index template" do
    get :index
    response.should render_template(:index)
  end
  
  it "show action should render show template" do
    get :show, id: UserProfileEntry.first
    response.should render_template(:show)
  end
  
  it "new action should render new template" do
    get :new
    response.should render_template(:new)
  end
  
  it "create action should render new template when model is invalid" do
    UserProfileEntry.any_instance.stubs(:valid?).returns(false)
    post :create
    response.should render_template(:new)
  end
  
  it "create action should redirect when model is valid" do
    UserProfileEntry.any_instance.stubs(:valid?).returns(true)
    post :create
    response.should redirect_to(user_profile_entry_url(assigns[:user_profile_entry]))
  end
  
  it "edit action should render edit template" do
    get :edit, id: UserProfileEntry.first
    response.should render_template(:edit)
  end
  
  it "update action should render edit template when model is invalid" do
    UserProfileEntry.any_instance.stubs(:valid?).returns(false)
    put :update, id: UserProfileEntry.first
    response.should render_template(:edit)
  end
  
  it "update action should redirect when model is valid" do
    UserProfileEntry.any_instance.stubs(:valid?).returns(true)
    put :update, id: UserProfileEntry.first
    response.should redirect_to(user_profile_entry_url(assigns[:user_profile_entry]))
  end
  
  it "destroy action should destroy model and redirect to index action" do
    user_profile_entry = UserProfileEntry.first
    delete :destroy, id: user_profile_entry
    response.should redirect_to(user_profile_entries_url)
    UserProfileEntry.exists?(user_profile_entry.id).should be_false
  end
end
