class ChangeInstructorIntroBiotoText < ActiveRecord::Migration

  def self.up
    change_table :instructors do |t|
      t.change :intro, :text
      t.change :bio, :text
    end
  end
  def self.down
    change_table :instructors do |t|
      t.change :intro, :string
      t.change :bio, :string
    end
  end

end
