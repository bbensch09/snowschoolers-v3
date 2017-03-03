class CreateContestants < ActiveRecord::Migration[5.0]
  def change
    create_table :contestants do |t|
      t.string :username
      t.string :hometown
      t.attachment :avatar

      t.timestamps
    end
  end
end
