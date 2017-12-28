class AddPlannedStartTimeToLessons < ActiveRecord::Migration[5.0]
  def change
  	add_column :lessons, :planned_start_time, :string
  end
end
