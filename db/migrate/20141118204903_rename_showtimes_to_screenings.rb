class RenameShowtimesToScreenings < ActiveRecord::Migration
  def change
    rename_table :showtimes, :screenings
  end
end
