class AddKidsEligibilityToInstructors < ActiveRecord::Migration
  def change
    add_column :instructors, :kids_eligibility, :boolean
    add_column :instructors, :seniors_eligibility, :boolean
    add_column :instructors, :adults_eligibility, :boolean
  end
end
