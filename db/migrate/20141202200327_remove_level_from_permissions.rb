class RemoveLevelFromPermissions < ActiveRecord::Migration
  def change
    remove_coulmn :permissions, :level
  end

  def down
    add_coulmn :permissions, :level, :enum, :limit => %(full reservations auditions)
  end
end
