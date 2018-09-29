class AddRentalFieldsToStudents < ActiveRecord::Migration[5.0]
  def change
  	add_column :students, :shoe_size, :string
  	add_column :students, :height_feet, :integer
  	add_column :students, :height_inches, :integer
  	add_column :students, :weight, :integer
  	add_column :students, :skier_type, :string
  	add_column :students, :board_direction, :string
  end
end
