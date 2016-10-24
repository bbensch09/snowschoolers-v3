class CreateSnowboardLevels < ActiveRecord::Migration
  def change
    create_table :snowboard_levels do |t|
      t.string :name
      t.integer :value

      t.timestamps
    end
  end
end
