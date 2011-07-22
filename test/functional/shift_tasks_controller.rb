require 'test_helper'

class ShiftTasksControllerTest < ActionController::TestCase
  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:shift_tasks)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create shift_task" do
    assert_difference('ShiftTask.count') do
      post :create, :shift_task => { }
    end

    assert_redirected_to shift_task_path(assigns(:shift_task))
  end

  test "should show shift_task" do
    get :show, :id => shift_tasks(:one).to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => shift_tasks(:one).to_param
    assert_response :success
  end

  test "should update shift_task" do
    put :update, :id => shift_tasks(:one).to_param, :shift_task => { }
    assert_redirected_to shift_task_path(assigns(:shift_task))
  end

  test "should destroy shift_task" do
    assert_difference('ShiftTask.count', -1) do
      delete :destroy, :id => shift_tasks(:one).to_param
    end

    assert_redirected_to shift_tasks_path
  end
end