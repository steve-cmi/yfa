class CreateInterests < ActiveRecord::Migration
  def change
    create_table :interests do |t|
      t.belongs_to :activity
      t.belongs_to :person
      t.timestamps
    end
  end
end
