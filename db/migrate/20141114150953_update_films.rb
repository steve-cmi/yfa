class UpdateFilms < ActiveRecord::Migration
  def up
    remove_column :films, :writer
    remove_column :films, :picture_meta
    remove_column :films, :flickr_id
    remove_column :films, :location
    remove_column :films, :aud_files
    remove_column :films, :public_aud_info
    remove_column :films, :url_key
    remove_column :films, :accent_color
    remove_column :film_positions, :assistant
    remove_column :showtimes, :email_sent
    rename_column :showtimes, :timestamp, :starts_at
    rename_column :auditions, :timestamp, :starts_at
  end

  def down
    add_column :films, :writer, :string
    add_column :films, :picture_meta, :string
    add_column :films, :flickr_id, :string
    add_column :films, :location, :string
    add_column :films, :aud_files, :text
    add_column :films, :public_aud_info, :boolean
    add_column :films, :url_key, :string
    add_column :films, :accent_color, :enum, :limit => [:red, :yellow, :green, :dark_blue, :blue, :light_blue, :black]
    add_column :film_positions, :assistant, :enum, :limit => %w(Associate Assistant)
    add_column :showtimes, :email_sent, :boolean
    rename_column :showtimes, :timestamp, :starts_at
    rename_column :auditions, :timestamp, :starts_at
  end
end
