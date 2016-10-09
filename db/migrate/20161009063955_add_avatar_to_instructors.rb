class AddAvatarToInstructors < ActiveRecord::Migration
  def self.up
    change_table :instructors do |t|
      t.attachment :avatar
    end
  end

  def self.down
    drop_attached_file :instructors, :avatar
  end
end
