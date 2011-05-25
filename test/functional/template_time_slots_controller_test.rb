require 'test_helper'

class TemplateTimeSlotsControllerTest < ActionController::TestCase
  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:template_time_slots)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create template_time_slot" do
    assert_difference('TemplateTimeSlot.count') do
      post :create, :template_time_slot => { }
    end

    assert_redirected_to template_time_slot_path(assigns(:template_time_slot))
  end

  test "should show template_time_slot" do
    get :show, :id => template_time_slots(:one).to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => template_time_slots(:one).to_param
    assert_response :success
  end

  test "should update template_time_slot" do
    put :update, :id => template_time_slots(:one).to_param, :template_time_slot => { }
    assert_redirected_to template_time_slot_path(assigns(:template_time_slot))
  end

  test "should destroy template_time_slot" do
    assert_difference('TemplateTimeSlot.count', -1) do
      delete :destroy, :id => template_time_slots(:one).to_param
    end

    assert_redirected_to template_time_slots_path
  end
end
