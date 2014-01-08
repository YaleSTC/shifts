require 'test_helper'

class RequestedShiftsControllerTest < ActionController::TestCase
  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:requested_shifts)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create requested_shift" do
    assert_difference('RequestedShift.count') do
      post :create, requested_shift: { }
    end

    assert_redirected_to requested_shift_path(assigns(:requested_shift))
  end

  test "should show requested_shift" do
    get :show, id: requested_shifts(:one).to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: requested_shifts(:one).to_param
    assert_response :success
  end

  test "should update requested_shift" do
    put :update, id: requested_shifts(:one).to_param, requested_shift: { }
    assert_redirected_to requested_shift_path(assigns(:requested_shift))
  end

  test "should destroy requested_shift" do
    assert_difference('RequestedShift.count', -1) do
      delete :destroy, id: requested_shifts(:one).to_param
    end

    assert_redirected_to requested_shifts_path
  end
end
