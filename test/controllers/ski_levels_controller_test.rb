require 'test_helper'

class SkiLevelsControllerTest < ActionController::TestCase
  setup do
    @ski_level = ski_levels(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:ski_levels)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create ski_level" do
    assert_difference('SkiLevel.count') do
      post :create, ski_level: { name: @ski_level.name, value: @ski_level.value }
    end

    assert_redirected_to ski_level_path(assigns(:ski_level))
  end

  test "should show ski_level" do
    get :show, id: @ski_level
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @ski_level
    assert_response :success
  end

  test "should update ski_level" do
    patch :update, id: @ski_level, ski_level: { name: @ski_level.name, value: @ski_level.value }
    assert_redirected_to ski_level_path(assigns(:ski_level))
  end

  test "should destroy ski_level" do
    assert_difference('SkiLevel.count', -1) do
      delete :destroy, id: @ski_level
    end

    assert_redirected_to ski_levels_path
  end
end
