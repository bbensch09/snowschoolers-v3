class CreateConversations < ActiveRecord::Migration
  def change
    create_table :conversations do |t|
      t.integer :instructor_id
      t.integer :requester_id

      t.timestamps
    end
  end
end
