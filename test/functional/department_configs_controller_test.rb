require 'test_helper'

class DepartmentConfigsControllerTest < ActionController::TestCase
  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:department_configs)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create department_config" do
    assert_difference('DepartmentConfig.count') do
      post :create, department_config: { }
    end

    assert_redirected_to department_config_path(assigns(:department_config))
  end

  test "should show department_config" do
    get :show, id: department_configs(:one).to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: department_configs(:one).to_param
    assert_response :success
  end

  test "should update department_config" do
    put :update, id: department_configs(:one).to_param, department_config: { }
    assert_redirected_to department_config_path(assigns(:department_config))
  end

  test "should destroy department_config" do
    assert_difference('DepartmentConfig.count', -1) do
      delete :destroy, id: department_configs(:one).to_param
    end

    assert_redirected_to department_configs_path
  end
end
