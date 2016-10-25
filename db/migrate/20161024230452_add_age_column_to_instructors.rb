class AddAgeColumnToInstructors < ActiveRecord::Migration
  def change
    add_column :instructors, :age, :integer
    add_column :instructors, :dob, :date
  end
end
