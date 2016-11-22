class AddOriginalUrlToOpportunities < ActiveRecord::Migration
  def change
    add_column :opportunities, :original_url, :string
  end
end
