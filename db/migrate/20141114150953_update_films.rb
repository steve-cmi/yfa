class UpdateFilms < ActiveRecord::Migration
  def change
    remove_column :films, :writer, :string
    remove_column :films, :picture_meta, :string
    remove_column :films, :flickr_id, :string
    remove_column :films, :location, :string
    remove_column :films, :aud_files, :text
    remove_column :films, :public_aud_info, :boolean
    remove_column :film_positions, :assistant, :string
  end
end
