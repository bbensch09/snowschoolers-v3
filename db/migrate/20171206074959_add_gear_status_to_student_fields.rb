class AddGearStatusToStudentFields < ActiveRecord::Migration[5.0]
  def change
    add_column :students, :needs_rental, :boolean
  end
end
