class AddColumnsToCalendarBlocks < ActiveRecord::Migration[5.0]
  def change
  	add_column :calendar_blocks, :date, :date
  	add_column :calendar_blocks, :state, :string
  	add_column :calendar_blocks, :prime_day, :boolean
  end
end
