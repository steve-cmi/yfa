class CreateCarousels < ActiveRecord::Migration
  def change
    create_table :carousels do |t|
      t.string :title
      t.string :body
      t.string :link
      t.boolean :active, default: true
      t.integer :position
      t.attachment :image
      t.timestamps
    end
  end
end
