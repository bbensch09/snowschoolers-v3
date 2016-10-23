class CreateJoinTableSkiLevelInstructor < ActiveRecord::Migration
  def change
        create_join_table :instructors, :ski_levels do |t|
        end
  end
end
