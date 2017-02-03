class AddNpsToReviews < ActiveRecord::Migration[5.0]
  def change
        add_column :reviews, :nps, :integer
  end
end
