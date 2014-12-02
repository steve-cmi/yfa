class UpdateFilms < ActiveRecord::Migration
  def change
    remove_column :films, :writer, :string
    remove_column :films, :picture_meta, :string
    remove_column :films, :flickr_id, :string
    remove_column :films, :location, :string
    remove_column :films, :aud_files, :text
    remove_column :films, :public_aud_info, :boolean
    remove_column :films, :url_key, :string
    remove_column :film_positions, :assistant, :string
    remove_column :showtimes, :email_sent, :boolean
    rename_column :showtimes, :timestamp, :starts_at
    rename_column :auditions, :timestamp, :starts_at
  end
end
