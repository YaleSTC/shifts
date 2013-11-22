require 'test_helper'

class RolesControllerTest < ActionController::TestCase
  def test_index
    get :index
    assert_template 'index'
  end
  
  def test_show
    get :show, id: Role.first
    assert_template 'show'
  end
  
  def test_new
    get :new
    assert_template 'new'
  end
  
  def test_create_invalid
    Role.any_instance.stubs(:valid?).returns(false)
    post :create
    assert_template 'new'
  end
  
  def test_create_valid
    Role.any_instance.stubs(:valid?).returns(true)
    post :create
    assert_redirected_to role_url(assigns(:role))
  end
  
  def test_edit
    get :edit, id: Role.first
    assert_template 'edit'
  end
  
  def test_update_invalid
    Role.any_instance.stubs(:valid?).returns(false)
    put :update, id: Role.first
    assert_template 'edit'
  end
  
  def test_update_valid
    Role.any_instance.stubs(:valid?).returns(true)
    put :update, id: Role.first
    assert_redirected_to role_url(assigns(:role))
  end
  
  def test_destroy
    role = Role.first
    delete :destroy, id: role
    assert_redirected_to roles_url
    assert !Role.exists?(role.id)
  end
end
