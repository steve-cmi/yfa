class CreateVideos < ActiveRecord::Migration
  def change
    create_table :videos do |t|
      t.belongs_to :film
      t.string :name
      t.string :link
      t.integer :position
      t.timestamps
    end
  end
end
