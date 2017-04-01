class CreateSections < ActiveRecord::Migration[5.0]
  def change
    create_table :sections do |t|
      t.string :age_group
      t.string :lesson_type
      t.integer :sport_id
      t.string :instructor_id
      t.string :status
      t.string :level
      t.integer :capacity
      t.date :date

      t.timestamps
    end
    add_column :lessons, :section_id, :string
  end
end
