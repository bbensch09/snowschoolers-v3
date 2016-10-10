class CreateCalendarBlocks < ActiveRecord::Migration
  def change
    create_table :calendar_blocks do |t|
      t.integer :instructor_id
      t.integer :lesson_time_id
      t.string :status

      t.timestamps
    end
  end
end
