class CreateOpportunitySource < ActiveRecord::Migration
  def change
    create_table :sources do |t|
      t.string :name
      t.timestamps null: false
    end

    add_reference :opportunities, :source, index: true
	add_foreign_key :opportunities, :sources
  end
end
