class CreateInstructorsSportsJoinTable < ActiveRecord::Migration[5.0]
  def change
        create_join_table :instructors, :sports do |t|
        end
  end
end
