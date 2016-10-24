class CreateSkiLevels < ActiveRecord::Migration
  def change
    create_table :ski_levels do |t|
      t.string :name
      t.integer :value

      t.timestamps
    end
  end
end
