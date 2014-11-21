class AddLocationToScreenings < ActiveRecord::Migration
  def change
    add_column :screenings, :location, :string
    add_column :screenings, :building_id, :integer
  end
end
