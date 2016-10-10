class AddHowDidYouHearToInstructors < ActiveRecord::Migration
  def change
      add_column :instructors, :how_did_you_hear, :string
  end
end
