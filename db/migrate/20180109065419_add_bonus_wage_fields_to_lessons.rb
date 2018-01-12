class AddBonusWageFieldsToLessons < ActiveRecord::Migration[5.0]
  def change
  	add_column :lessons, :hourly_bonus, :integer
  	add_column :lessons, :bonus_category, :string
  	add_column :lessons, :additional_info, :text
  end
end
