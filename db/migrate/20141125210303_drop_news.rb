class DropNews < ActiveRecord::Migration
  def up
    drop_table :news
  end

  def down
    create_table :news do |t|
      t.string :title
      t.string :poster
      t.text :text
      t.timestamps
    end
  end
end
