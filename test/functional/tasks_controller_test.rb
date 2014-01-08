require 'test_helper'

class TasksControllerTest < ActionController::TestCase
  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:tasks)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create task" do
    assert_difference('Task.count') do
      post :create, task: { }
    end

    assert_redirected_to task_path(assigns(:task))
  end

  test "should show task" do
    get :show, id: tasks(:one).to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: tasks(:one).to_param
    assert_response :success
  end

  test "should update task" do
    put :update, id: tasks(:one).to_param, task: { }
    assert_redirected_to task_path(assigns(:task))
  end

  test "should destroy task" do
    assert_difference('Task.count', -1) do
      delete :destroy, id: tasks(:one).to_param
    end

    assert_redirected_to tasks_path
  end
end