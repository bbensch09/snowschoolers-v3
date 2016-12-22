class AddHdyhToLessons < ActiveRecord::Migration[5.0]
  def change
          add_column :lessons, :how_did_you_hear, :string
  end
end
