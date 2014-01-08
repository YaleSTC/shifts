require 'test_helper'

class DepartmentsControllerTest < ActionController::TestCase
  def test_index
    get :index
    assert_template 'index'
  end
  
  def test_show
    get :show, id: Department.first
    assert_template 'show'
  end
  
  def test_new
    get :new
    assert_template 'new'
  end
  
  def test_create_invalid
    Department.any_instance.stubs(:valid?).returns(false)
    post :create
    assert_template 'new'
  end
  
  def test_create_valid
    Department.any_instance.stubs(:valid?).returns(true)
    post :create
    assert_redirected_to department_url(assigns(:department))
  end
  
  def test_edit
    get :edit, id: Department.first
    assert_template 'edit'
  end
  
  def test_update_invalid
    Department.any_instance.stubs(:valid?).returns(false)
    put :update, id: Department.first
    assert_template 'edit'
  end
  
  def test_update_valid
    Department.any_instance.stubs(:valid?).returns(true)
    put :update, id: Department.first
    assert_redirected_to department_url(assigns(:department))
  end
  
  def test_destroy
    department = Department.first
    delete :destroy, id: department
    assert_redirected_to departments_url
    assert !Department.exists?(department.id)
  end
end
