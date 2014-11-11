class RenameShowsToFilms < ActiveRecord::Migration
  def up
    rename_table :shows, :films
    rename_table :show_positions, :film_positions
    rename_column :auditions, :show_id, :film_id
    rename_column :permissions, :show_id, :film_id
    rename_column :film_positions, :show_id, :film_id
    rename_column :showtimes, :show_id, :film_id
  end

  def down
    rename_table :films, :shows
    rename_table :film_positions, :show_positions
    rename_column :auditions, :film_id, :show_id
    rename_column :permissions, :film_id, :show_id
    rename_column :show_positions, :film_id, :show_id
    rename_column :showtimes, :film_id, :show_id
  end
end
