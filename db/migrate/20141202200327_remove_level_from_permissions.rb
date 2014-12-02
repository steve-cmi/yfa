class RemoveLevelFromPermissions < ActiveRecord::Migration
  def change
    remove_column :permissions, :level
  end

  def down
    add_coulmn :permissions, :level, :enum, :limit => %(full reservations auditions)
  end
end
