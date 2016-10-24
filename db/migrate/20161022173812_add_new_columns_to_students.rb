class AddNewColumnsToStudents < ActiveRecord::Migration
  def change
            add_column :students, :requester_id, :integer
            add_column :students, :most_recent_experience, :string
            add_column :students, :most_recent_level, :string
            add_column :students, :other_sports_experience, :text
            add_column :lessons, :focus_area, :string
  end
end
