class CreateReportCards < ActiveRecord::Migration[6.0]
  def change
    create_table :report_cards do |t|
      t.integer :student_id
      t.integer :lesson_id
      t.integer :instructor_id
      t.string :attitude_grade
      t.string :safety_grade
      t.string :effort_grade
      t.integer :ability_level
      t.string :activty
      t.text :qualitative_feeback
      t.string :balance
      t.string :edge_control
      t.string :pressure_control
      t.string :rotary_control

      t.timestamps
    end
  end
end
