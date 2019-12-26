json.extract! report_card, :id, :student_id, :lesson_id, :instructor_id, :attitude_grade, :safety_grade, :effort_grade, :ability_level, :activty, :qualitative_feeback, :balance, :edge_control, :pressure_control, :rotary_control, :created_at, :updated_at
json.url report_card_url(report_card, format: :json)
