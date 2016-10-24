require 'test_helper'

class SnowboardLevelsControllerTest < ActionController::TestCase
  setup do
    @snowboard_level = snowboard_levels(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:snowboard_levels)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create snowboard_level" do
    assert_difference('SnowboardLevel.count') do
      post :create, snowboard_level: { name: @snowboard_level.name, value: @snowboard_level.value }
    end

    assert_redirected_to snowboard_level_path(assigns(:snowboard_level))
  end

  test "should show snowboard_level" do
    get :show, id: @snowboard_level
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @snowboard_level
    assert_response :success
  end

  test "should update snowboard_level" do
    patch :update, id: @snowboard_level, snowboard_level: { name: @snowboard_level.name, value: @snowboard_level.value }
    assert_redirected_to snowboard_level_path(assigns(:snowboard_level))
  end

  test "should destroy snowboard_level" do
    assert_difference('SnowboardLevel.count', -1) do
      delete :destroy, id: @snowboard_level
    end

    assert_redirected_to snowboard_levels_path
  end
end
