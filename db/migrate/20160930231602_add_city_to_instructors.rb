class AddCityToInstructors < ActiveRecord::Migration
  def change
        add_column :instructors, :city, :string
  end
end
