class UpdateFilms < ActiveRecord::Migration
  def up
    remove_column :films, :writer
    remove_column :films, :picture_meta
    remove_column :films, :flickr_id
    remove_column :films, :location
    remove_column :films, :aud_files
    remove_column :films, :public_aud_info
    remove_column :film_positions, :assistant
  end
  def down
    add_column :films, :writer, :string
    add_column :films, :picture_meta, :string
    add_column :films, :flickr_id, :string
    add_column :films, :location, :string
    add_column :films, :aud_files, :text
    add_column :films, :public_aud_info, :boolean
    add_column :film_positions, :assistant, :enum, :limit => ['Associate', 'Assistant']
  end
end
