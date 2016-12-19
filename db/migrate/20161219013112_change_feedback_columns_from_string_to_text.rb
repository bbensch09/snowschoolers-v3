class ChangeFeedbackColumnsFromStringToText < ActiveRecord::Migration[5.0]
  def change
    change_column :lessons, :public_feedback_for_student, :text
    change_column :lessons, :private_feedback_for_student, :text
    change_column :reviews, :review, :text
  end
end
