class AddSkipValidationsToLesson < ActiveRecord::Migration[5.0]
  def change
  	  	add_column :lessons, :skip_validations, :boolean
  end
end
