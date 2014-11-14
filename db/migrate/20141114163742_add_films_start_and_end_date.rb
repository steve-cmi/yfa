class AddFilmsStartAndEndDate < ActiveRecord::Migration
  def change
    add_column :films, :start_date, :date
    add_column :films, :end_date, :date
  end
end
