class CreateActivities < ActiveRecord::Migration
  def change
    create_table :activities do |t|
      t.string :name
      t.string :key
      t.integer :position
      t.timestamps
    end
  end
end
