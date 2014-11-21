class CreateGenres < ActiveRecord::Migration
  def change
    remove_column :films, :category, :string

    create_table :genres do |t|
      t.string :name
      t.string :slug
      t.integer :position
      t.timestamps
    end

    create_table :films_genres do |t|
      t.belongs_to :film
      t.belongs_to :genre
      t.timestamps
    end
  end
end
