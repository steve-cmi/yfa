class AddMinutesToScreenings < ActiveRecord::Migration
  def change
    add_column :screenings, :minutes, :integer
  end
end
