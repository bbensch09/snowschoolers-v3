class AddRequesterNametoLessons < ActiveRecord::Migration[5.0]
  def change
        add_column :lessons, :requester_name, :string
  end
end
