class AddOriginalPublishDateToOpportunities < ActiveRecord::Migration
  def change
  	add_column :opportunities, :original_publish_date, :datetime
  end
end
