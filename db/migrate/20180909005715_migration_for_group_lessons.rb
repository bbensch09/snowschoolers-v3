class MigrationForGroupLessons < ActiveRecord::Migration[5.0]
  def change
  	  	add_column :sections, :slot, :string
  end
end
