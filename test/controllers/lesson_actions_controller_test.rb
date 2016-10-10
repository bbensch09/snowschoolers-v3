require 'test_helper'

class LessonActionsControllerTest < ActionController::TestCase
  setup do
    @lesson_action = lesson_actions(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:lesson_actions)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create lesson_action" do
    assert_difference('LessonAction.count') do
      post :create, lesson_action: { action: @lesson_action.action, instructor_id: @lesson_action.instructor_id, lesson_id: @lesson_action.lesson_id }
    end

    assert_redirected_to lesson_action_path(assigns(:lesson_action))
  end

  test "should show lesson_action" do
    get :show, id: @lesson_action
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @lesson_action
    assert_response :success
  end

  test "should update lesson_action" do
    patch :update, id: @lesson_action, lesson_action: { action: @lesson_action.action, instructor_id: @lesson_action.instructor_id, lesson_id: @lesson_action.lesson_id }
    assert_redirected_to lesson_action_path(assigns(:lesson_action))
  end

  test "should destroy lesson_action" do
    assert_difference('LessonAction.count', -1) do
      delete :destroy, id: @lesson_action
    end

    assert_redirected_to lesson_actions_path
  end
end
