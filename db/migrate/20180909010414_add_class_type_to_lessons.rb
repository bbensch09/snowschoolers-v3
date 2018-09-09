class AddClassTypeToLessons < ActiveRecord::Migration[5.0]
  def change
  	  	add_column :lessons, :class_type, :string
  end
end
