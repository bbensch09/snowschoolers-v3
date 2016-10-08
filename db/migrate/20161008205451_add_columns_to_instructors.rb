class AddColumnsToInstructors < ActiveRecord::Migration
  def change
            add_column :instructors, :adults_initial_rank, :integer
            add_column :instructors, :kids_initial_rank, :integer
            add_column :instructors, :overall_initial_rank, :integer
  end
end
