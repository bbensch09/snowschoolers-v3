class CreateJoinTableReportCardSCardSkill < ActiveRecord::Migration[6.0]
  def change
  	create_join_table :skills, :report_cards, table_name: :skills_practiced
  	create_join_table :skills, :report_cards, table_name: :skills_recommended
  end
end
