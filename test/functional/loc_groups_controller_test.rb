require 'test_helper'

class LocGroupsControllerTest < ActionController::TestCase
  def test_index
    get :index
    assert_template 'index'
  end
  
  def test_show
    get :show, id: LocGroup.first
    assert_template 'show'
  end
  
  def test_new
    get :new
    assert_template 'new'
  end
  
  def test_create_invalid
    LocGroup.any_instance.stubs(:valid?).returns(false)
    post :create
    assert_template 'new'
  end
  
  def test_create_valid
    LocGroup.any_instance.stubs(:valid?).returns(true)
    post :create
    assert_redirected_to loc_group_url(assigns(:loc_group))
  end
  
  def test_edit
    get :edit, id: LocGroup.first
    assert_template 'edit'
  end
  
  def test_update_invalid
    LocGroup.any_instance.stubs(:valid?).returns(false)
    put :update, id: LocGroup.first
    assert_template 'edit'
  end
  
  def test_update_valid
    LocGroup.any_instance.stubs(:valid?).returns(true)
    put :update, id: LocGroup.first
    assert_redirected_to loc_group_url(assigns(:loc_group))
  end
  
  def test_destroy
    loc_group = LocGroup.first
    delete :destroy, id: loc_group
    assert_redirected_to loc_groups_url
    assert !LocGroup.exists?(loc_group.id)
  end
end
