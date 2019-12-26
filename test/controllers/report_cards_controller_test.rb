require 'test_helper'

class ReportCardsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @report_card = report_cards(:one)
  end

  test "should get index" do
    get report_cards_url
    assert_response :success
  end

  test "should get new" do
    get new_report_card_url
    assert_response :success
  end

  test "should create report_card" do
    assert_difference('ReportCard.count') do
      post report_cards_url, params: { report_card: { ability_level: @report_card.ability_level, activty: @report_card.activty, attitude_grade: @report_card.attitude_grade, balance: @report_card.balance, edge_control: @report_card.edge_control, effort_grade: @report_card.effort_grade, instructor_id: @report_card.instructor_id, lesson_id: @report_card.lesson_id, pressure_control: @report_card.pressure_control, qualitative_feeback: @report_card.qualitative_feeback, rotary_control: @report_card.rotary_control, safety_grade: @report_card.safety_grade, student_id: @report_card.student_id } }
    end

    assert_redirected_to report_card_url(ReportCard.last)
  end

  test "should show report_card" do
    get report_card_url(@report_card)
    assert_response :success
  end

  test "should get edit" do
    get edit_report_card_url(@report_card)
    assert_response :success
  end

  test "should update report_card" do
    patch report_card_url(@report_card), params: { report_card: { ability_level: @report_card.ability_level, activty: @report_card.activty, attitude_grade: @report_card.attitude_grade, balance: @report_card.balance, edge_control: @report_card.edge_control, effort_grade: @report_card.effort_grade, instructor_id: @report_card.instructor_id, lesson_id: @report_card.lesson_id, pressure_control: @report_card.pressure_control, qualitative_feeback: @report_card.qualitative_feeback, rotary_control: @report_card.rotary_control, safety_grade: @report_card.safety_grade, student_id: @report_card.student_id } }
    assert_redirected_to report_card_url(@report_card)
  end

  test "should destroy report_card" do
    assert_difference('ReportCard.count', -1) do
      delete report_card_url(@report_card)
    end

    assert_redirected_to report_cards_url
  end
end
