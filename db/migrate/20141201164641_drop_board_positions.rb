class DropBoardPositions < ActiveRecord::Migration
  def change
    drop_table :board_positions do |t|
      t.string   :position
      t.integer  :year
      t.integer  :person_id
      t.string   :extra
      t.datetime :created_at, :null => false
      t.datetime :updated_at, :null => false
    end
  end
end
