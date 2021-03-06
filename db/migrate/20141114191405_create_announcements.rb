class CreateAnnouncements < ActiveRecord::Migration
  def change
    create_table :announcements do |t|
      t.string :title
      t.string :body
      t.string :link_text
      t.string :link_url
      t.boolean :active
      t.timestamps
    end
  end
end
