class AddKeyToPositions < ActiveRecord::Migration
  def change
    add_column :positions, :key, :string
  end
end
