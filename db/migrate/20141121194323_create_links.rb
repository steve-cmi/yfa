class CreateLinks < ActiveRecord::Migration
  def change
    create_table :links do |t|
      t.belongs_to :item, :polymorphic => true
      t.string :name
      t.string :url
      t.integer :position
      t.timestamps
    end
  end
end
