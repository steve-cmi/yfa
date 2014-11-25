class CreatePages < ActiveRecord::Migration
  def change
    create_table :pages do |t|
      t.string :title
      t.string :slug
      t.text :lead
      t.text :content
      t.attachment :image
      t.string :menu
      t.string :menu_title
      t.integer :position
      t.timestamps
    end
  end
end
