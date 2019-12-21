require "application_system_test_case"

class ReportCardsTest < ApplicationSystemTestCase
  setup do
    @report_card = report_cards(:one)
  end

  test "visiting the index" do
    visit report_cards_url
    assert_selector "h1", text: "Report Cards"
  end

  test "creating a Report card" do
    visit report_cards_url
    click_on "New Report Card"

    fill_in "Ability level", with: @report_card.ability_level
    fill_in "Activty", with: @report_card.activty
    fill_in "Attitude grade", with: @report_card.attitude_grade
    fill_in "Balance", with: @report_card.balance
    fill_in "Edge control", with: @report_card.edge_control
    fill_in "Effort grade", with: @report_card.effort_grade
    fill_in "Instructor", with: @report_card.instructor_id
    fill_in "Lesson", with: @report_card.lesson_id
    fill_in "Pressure control", with: @report_card.pressure_control
    fill_in "Qualitative feeback", with: @report_card.qualitative_feeback
    fill_in "Rotary control", with: @report_card.rotary_control
    fill_in "Safety grade", with: @report_card.safety_grade
    fill_in "Student", with: @report_card.student_id
    click_on "Create Report card"

    assert_text "Report card was successfully created"
    click_on "Back"
  end

  test "updating a Report card" do
    visit report_cards_url
    click_on "Edit", match: :first

    fill_in "Ability level", with: @report_card.ability_level
    fill_in "Activty", with: @report_card.activty
    fill_in "Attitude grade", with: @report_card.attitude_grade
    fill_in "Balance", with: @report_card.balance
    fill_in "Edge control", with: @report_card.edge_control
    fill_in "Effort grade", with: @report_card.effort_grade
    fill_in "Instructor", with: @report_card.instructor_id
    fill_in "Lesson", with: @report_card.lesson_id
    fill_in "Pressure control", with: @report_card.pressure_control
    fill_in "Qualitative feeback", with: @report_card.qualitative_feeback
    fill_in "Rotary control", with: @report_card.rotary_control
    fill_in "Safety grade", with: @report_card.safety_grade
    fill_in "Student", with: @report_card.student_id
    click_on "Update Report card"

    assert_text "Report card was successfully updated"
    click_on "Back"
  end

  test "destroying a Report card" do
    visit report_cards_url
    page.accept_confirm do
      click_on "Destroy", match: :first
    end

    assert_text "Report card was successfully destroyed"
  end
end
