class CreateSkills < ActiveRecord::Migration[6.0]
  def change
    create_table :skills do |t|
      t.integer :sport_id
      t.string :name
      t.string :description
      t.string :ability_category
      t.integer :ability_level

      t.timestamps
    end
  end
end
