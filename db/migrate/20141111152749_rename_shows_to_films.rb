class RenameShowsToFilms < ActiveRecord::Migration
  def change
    rename_table :shows, :films
    rename_table :show_positions, :film_positions
    rename_column :auditions, :show_id, :film_id
    rename_column :permissions, :show_id, :film_id
    rename_column :film_positions, :show_id, :film_id
    rename_column :showtimes, :show_id, :film_id
  end
end
