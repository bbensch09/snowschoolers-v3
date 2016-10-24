class CreateJoinTableSnowboardLevelInstructor < ActiveRecord::Migration
  def change
        create_join_table :instructors, :snowboard_levels do |t|
        end
  end
end
